<!DOCTYPE html>
<html lang="en">
  <head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Meie raadio</title>

    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.6.3/css/all.css" integrity="sha384-UHRtZLI+pbxtHCWp1t77Bi1L4ZtiqrqD80Kn4Z8NTSRyMA2Fd33n5dQ8lWUE00s/" crossorigin="anonymous">
    
    <link rel="stylesheet" href="css/bootstrap4-daydream.min.css">
    
    
    <link href="https://fonts.googleapis.com/css?family=Open+Sans|Oswald|Shadows+Into+Light" rel="stylesheet">
    
    
  </head>
  <body>

<div class="jumbotron bg-primary text-center text-white mb-0 radius-0">
  <div class="container">

    <h1 class="display-3 text-white text-handwriting text-uppercase">Meie</h1>
    <h1 class="display-1 text-success text-uppercase title-margin-fix">raadio</h1>

    <div>
      <audio id="stream" xmlns="http://www.w3.org/1999/xhtml" controls="controls" preload="none"><source src="http://192.168.1.12:8000/raadio" type="audio/mpeg" /></audio>
    </div>
  </div>
</div>

<?php
$files = glob('saated/*.mp3');
if (count($files) > 0) {

echo '<!--old_show_section-->',"\n"
.'  <div class="container py-5 text-center">',"\n"
.'    <h1>Järelkuulatavad saated</h1>',"\n"
.'    <div class="container">',"\n"
.'      <!-- https://www.w3schools.com/bootstrap/bootstrap_collapse.asp -->',"\n"
.'      <div class="panel-group" id="accordion">',"\n"
.'          <!--old_shows-->';

// reading files from a directory https://stackoverflow.com/a/4560953
$x = 0;
foreach(glob('saated/*.mp3') as $file) { $x++; echo 
'        <div class="panel panel-default">',"\n"
.'          <div class="panel-heading">',"\n"
.'          <h4 class="panel-title">',"\n"
.'              <a data-toggle="collapse" data-parent="#accordion" href="#collapse'.$x.'">'. $file .'</a>',"\n"
.'               </h4>',"\n"
.'                </div>',"\n"
.'                 <div id="collapse'.$x.'" class="panel-collapse collapse in">',"\n"
.'             <audio id="recordings" xmlns="http://www.w3.org/1999/xhtml" controls="controls" preload="none"><source src="http://192.168.1.12/' .$file. '" type="audio/mpeg" /></audio>',"\n"
.'            </div>',"\n"
.'        </div>'
;}
echo          '<!--/old_shows-->',"\n"
.'      </div>',"\n"
.'    </div>',"\n"
.'  </div>',"\n"
.'<!--/old_show_section-->';
}
?>
    <!-- Optional JavaScript -->
    <!-- jQuery first, then Popper.js, then Bootstrap JS -->

  <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
  <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>

  </body>
</html>
