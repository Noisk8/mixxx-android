#pragma once

#include <QSGMaterial>

namespace rendergraph {
class BaseMaterial;
} // namespace rendergraph

class rendergraph::BaseMaterial : public QSGMaterial {
  protected:
    BaseMaterial() = default;

  public:
    QSGMaterialShader* createShader(QSGRendererInterface::RenderMode) const override;

    int compare(const QSGMaterial* other) const override;

    /// Copies the uniforms into buf if they changed, or always with force.
    /// Returns true if buf was written.
    bool updateUniformsByteArray(QByteArray* buf, bool force);
};
