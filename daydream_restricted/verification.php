<?php
session_start();
$hashedkey = '$2y$10$jZ8G8YA/b6sAIUMYDsBYNeV.O6p8Paz/6B1GZmK5Atm96mvm8ceOa';
# Create a hash for a password with hashgenerator.php; in this case, I used "test1234"
if (isset($_SESSION["verified"]) && $_SESSION["verified"]) {
  header("Location: index.php");
  # Check if a user has been previously verified first, in order to redirect them as quickly as possible.
}

if (isset($_POST["key"])) {
  $key = trim($_POST["key"]);
  $verifiedpassword = password_verify(
    base64_encode(
      hash("sha256", $key, true)
    ),
    $hashedkey
  );
  # Sanitized input to make it easier the enter in the password; it is very easy to strengthen these restrictions, or lessen them.
  if ($verifiedpassword) {
    $_SESSION["verified"] = true;
    $whitelist = ["/index.php"];
    # Add any other pages you wish to be accessible through the continue param.
    $nextpage = $_GET["continue"];
    if (isset($nextpage) && in_array($nextpage, $whitelist)) {
      header("Location: $nextpage");
    } else {
      header("Location: /index.php");
    }
  } else {
    $error = "See salasõna ei sobi!";
  }
}
?>
<!DOCTYPE html>
<html lang="en">
  <head>
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
  </div>
</div>

  <div class="container py-5 text-center">
    <h1>Seis! Oled sa meie kooliga seotud?</h1>
    <div class="container">
    <p>Haridusasutusena võime õppeesmärgil kasutada autoriõigustega kaitstud materjali, kuid see pole avalikkusele kuulamiseks. </p>
    <p>Juriidilistel põhjustel tuleb kasutajal end tuvastada. </p>
     <div class="container py-5 text-center">
       <form class="form-check-inline text-center" action="verification.php<?php if (isset($_GET["continue"])) echo "?continue=" . htmlentities($_GET["continue"]); ?>" method="post" autocomplete="off">
          <label class="sr-only" for="key">Key</label>
           <div class="input-group mb-2 mr-sm-2 mb-sm-0 text-center">
             <input class="form-control" type="password" name="key" id="key" placeholder="Salasõna">
           </div>
         <input class="btn btn-primary" type="submit" value="Sisene">
       </form>
        <?php if (isset($error)) echo "    <p>$error</p>\n"; ?>
       </div>
    </div>
  </div>
    <!-- Optional JavaScript -->
    <!-- jQuery first, then Popper.js, then Bootstrap JS -->

  <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
  <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>

  </body>
</html>


