//PARAMS
const thickness = 20;
//

const canvas = document.getElementById("user_drawing");
const ctx = canvas.getContext("2d");

let drawing = false; // Flag to track if the user is drawing

// Start drawing when mouse is pressed down
canvas.addEventListener("mousedown", (e) => {
  drawing = true;
  draw(e); // Start drawing immediately
});

// Stop drawing when mouse is released, regardless of position
document.addEventListener("mouseup", () => {
  drawing = false;
  ctx.beginPath(); // Reset path to avoid connecting lines between strokes
});

// Stop drawing if the mouse leaves the canvas area
canvas.addEventListener("mouseleave", () => {
  drawing = false;
});

// Draw on the canvas while the mouse is moving
canvas.addEventListener("mousemove", (e) => {
  if (drawing) {
    draw(e);
  }
});

function draw(e) {
  // Calculate mouse position within the canvas
  const rect = canvas.getBoundingClientRect();
  const x = e.clientX - rect.left;
  const y = e.clientY - rect.top;

  // Set drawing properties
  ctx.fillStyle = "black";
  ctx.strokeStyle = "black";
  ctx.lineWidth = thickness * 2;

  // Draw a smooth pen line
  ctx.lineTo(x, y);
  ctx.stroke();
  ctx.beginPath(); // Reset path to avoid continuous line
  ctx.arc(x, y, thickness, 0, Math.PI * 2);
  ctx.fill();
  ctx.beginPath();
  ctx.moveTo(x, y);
}
function isCanvasNotEmpty() {
  const width = canvas.width;
  const height = canvas.height;

  // Get all pixel data from the canvas
  const imageData = ctx.getImageData(0, 0, width, height);
  const pixels = imageData.data;

  // Loop through pixels, check for non-transparent ones
  for (let i = 0; i < pixels.length; i += 4) {
    const r = pixels[i];
    const g = pixels[i + 1];
    const b = pixels[i + 2];
    const a = pixels[i + 3];

    // Check if the pixel is not transparent (you could also add a check if it's not white)
    if (a !== 0) {
      return true; // Canvas has content
    }
  }

  return false; // Canvas is empty
}
var sending = false;
function submitUserCanvas() {
  if (!isCanvasNotEmpty(canvas)) {
    alert("Canvas is empty! Please draw something before submitting.");
    return;
  }

  if (sending) return;
  sending = true;
  $("#processingOverlay").css({ display: "flex" });
  canvas.toBlob(function (blob) {
    const img = new Image();
    img.src = URL.createObjectURL(blob);

    img.onload = function () {
      const tempCanvas = document.createElement("canvas");
      tempCanvas.width = 255;
      tempCanvas.height = 255;
      const tempCtx = tempCanvas.getContext("2d");

      tempCtx.drawImage(img, 0, 0, 255, 255);

      tempCanvas.toBlob(function (resizedBlob) {
        const fd = new FormData();
        fd.append("canvas", resizedBlob, "user_drawing.png");

        $.ajax({
          url: "/traiter-canvas",
          type: "POST",
          data: fd,
          contentType: false,
          processData: false,
          success: function (res) {
            $("#number_drawing").html(res.text);
          },
          error: function (err) {
            console.error("Error:", err);
          },
          complete: function () {
            sending = false;
            $("#processingOverlay").css({ display: "none" });
          },
        });
      }, "image/png");

      // Clean up object URL
      URL.revokeObjectURL(img.src);
    };
  }, "image/png");
}

function resetCanvasInput() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  $("#number_drawing").empty();
}
