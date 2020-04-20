using Godot;
using System;
using System.Windows;
using System.Drawing;
using System.Windows.Forms;
using System.Drawing.Imaging;

public class ClipBoardUtils : Node
{
	// Member variables here, example:

	//Random rnd = new Random();
	
	public String get_formatted_date()
	{
		return DateTime.Now.ToString("D_yyyy-MM-dd_T_hh-mm-ss-fff");
	}

	public override void _Ready()
	{
		// Called every time the node is added to the scene.
		// Initialization here.
		GD.Print("Loaded C# module.");
		
		
	}
	
	public String get_image(){
		var random_base_name = get_formatted_date();
		//var random_base_name = DateTimeOffset.UtcNow.ToUnixTimeSeconds().ToString() +"_"+ rnd.Next().ToString();
		var file_name = $@"{OS.GetUserDataDir()}\{random_base_name}.png";

		//if (Clipboard.ContainsImage())
		//{
		//	GD.Print("Found image in clipboard");
		//	System.Drawing.Image clip_image = Clipboard.GetImage();
		//	clip_image.Save(
		//		file_name, System.Drawing.Imaging.ImageFormat.Png);

		//	return file_name;
		//	//var width = clip_image.Width;
		//	//var height = clip_image.Height;
		//	//var new_image = new Image();
		//	//new_image.CreateFromData(width, height,true, Image.Format.BptcRgba, clip_image);

		//}

		if (Clipboard.ContainsImage())
		{
			//GD.Print("Clipboard contains image.");

			// ImageUIElement.Source = Clipboard.GetImage(); // does not work
			System.Windows.Forms.IDataObject clipboardData = System.Windows.Forms.Clipboard.GetDataObject();
			if (clipboardData != null)
			{
				//GD.Print("Clipboard data retrieved.");

				if (clipboardData.GetDataPresent(System.Windows.Forms.DataFormats.Bitmap))
				{
					//GD.Print("Clipboard data has bitmap.");

					System.Drawing.Bitmap bitmap = (System.Drawing.Bitmap)clipboardData.GetData(System.Windows.Forms.DataFormats.Bitmap);
					//GD.Print("Cast to bitmap.");
					//GD.Print("Attempt to save to " + file_name);

					bitmap.Save(file_name, ImageFormat.Png);
					//ImageUIElement.Source = System.Windows.Interop.Imaging.CreateBitmapSourceFromHBitmap(bitmap.GetHbitmap(), IntPtr.Zero, Int32Rect.Empty, BitmapSizeOptions.FromEmptyOptions());
					//Console.WriteLine("Clipboard copied to UIElement");
					return file_name;
				}
			}
		}
		//GD.Print("No Image Found in Clipboard.");
		return null;
	}

	public String get_text()
	{
		if (Clipboard.ContainsText(TextDataFormat.Text))
		{
			string clipboardText = Clipboard.GetText(TextDataFormat.Text);
			return clipboardText;
		}
		return null;
	}

	public override void _Process(float delta)
	{
		// Called every frame. Delta is time since the last frame.
		// Update game logic here.
	}
}
