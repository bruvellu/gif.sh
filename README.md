# 🎥 gif.sh

Shell script for converting videos into high-quality animated GIFs.

Requires [FFmpeg](https://ffmpeg.org/). Based on the article [High quality GIF
with FFmpeg](http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html).

```
Usage:
	./gif.sh [<options>] -i input.avi -o output.gif
Required:
	-i input movie	.avi, .mp4, etc
	-o output gif	.gif
Optional:
	-s start time	<mm:ss>, defaults to 00:00
	-d duration	<seconds>, defaults to input duration
	-f fps		<frames-per-second>, defaults to input fps
	-x scale	<width-in-pixels>, defaults to input width
```
