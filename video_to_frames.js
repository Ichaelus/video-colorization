const youtubeUrl = process.argv[2]; // Sample: 'https://www.youtube.com/watch?v=dPnEXx1vwVA';
const FPS = parseInt(process.argv[3]); // Sample: 30

require('youtube-frames');
 
$ytvideo(youtubeUrl, 'video_output', {quality: 'highestaudio'}).download("./original_frames");
$ytvideo(youtubeUrl, 'video_output', {quality: 'highestvideo'}).download("./original_frames").toFrames(FPS);