#include "backend/basematerialshader.h"

#include <QSGTexture>

#include "rendergraph/material.h"

using namespace rendergraph;

bool BaseMaterialShader::updateUniformData(RenderState& state,
        QSGMaterial* newMaterial,
        QSGMaterial* oldMaterial) {
    // The uniform buffer may hold the uniforms of another material of the
    // same shader, e.g. after Qt rebuilt its render batches. Copying only
    // changed uniforms then drew a node with the color of another one, e.g.
    // a loop in the color of a disabled loop, which flickered.
    bool result = static_cast<Material*>(newMaterial)
                          ->updateUniformsByteArray(state.uniformData(),
                                  newMaterial != oldMaterial);
    QByteArray* buf = state.uniformData();

    // The copy above wrote the matrix of the uniforms cache too, which
    // materials don't keep up to date: write it whenever the buffer changed
    if (state.isMatrixDirty() || result) {
        const QMatrix4x4 m = state.combinedMatrix();
        memcpy(buf->data(), m.constData(), 64);
        result = true;
    }

    return result;
}

/// Override for QSGMaterialShader; this function is called by the Qt scene graph to prepare use of
/// sampled images in the shader, typically in the form of combined image samplers.
void BaseMaterialShader::updateSampledImage(RenderState& state,
        int binding,
        QSGTexture** texture,
        QSGMaterial* newMaterial,
        QSGMaterial* oldMaterial) {
    if (!newMaterial || !static_cast<Material*>(newMaterial)->texture(binding)) {
        *texture = nullptr;
        return;
    }
    *texture = static_cast<Material*>(newMaterial)->texture(binding)->backendTexture();
    (*texture)->commitTextureOperations(state.rhi(), state.resourceUpdateBatch());
}
