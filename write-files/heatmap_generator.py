import os
import uuid
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "..", "backend", "static", "heatmaps")


def generate_heatmap(values: dict, username: str) -> str:
    """Generate a gene expression heatmap PNG and return the filename."""
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    genes = list(values.keys())
    vals = np.array(list(values.values()), dtype=float).reshape(1, -1)

    fig, ax = plt.subplots(figsize=(14, 2.2))
    fig.patch.set_facecolor("#070d1a")
    ax.set_facecolor("#070d1a")

    cmap = mcolors.LinearSegmentedColormap.from_list(
        "hpv", ["#070d1a", "#3d7fff", "#00c6ff", "#0ee7b0"]
    )
    im = ax.imshow(vals, aspect="auto", cmap=cmap, vmin=0)

    ax.set_xticks(range(len(genes)))
    ax.set_xticklabels(genes, rotation=45, ha="right", fontsize=7, color="#b0c4de")
    ax.set_yticks([])

    for spine in ax.spines.values():
        spine.set_visible(False)

    plt.colorbar(im, ax=ax, orientation="vertical", pad=0.01, fraction=0.015)
    plt.tight_layout(pad=0.5)

    filename = f"heatmap_{username}_{uuid.uuid4().hex[:8]}.png"
    filepath = os.path.join(OUTPUT_DIR, filename)
    plt.savefig(filepath, dpi=100, bbox_inches="tight", facecolor=fig.get_facecolor())
    plt.close(fig)

    return filename
