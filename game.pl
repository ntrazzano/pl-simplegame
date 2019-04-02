#!perl
# Copyright 2005 Neil Razzano
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

use Tk;
use strict;

#changeable variables
my $angle_turn = .3;

#global vars
my ($x,$y) = (0,0);
my $angle;
my @shots_fired;
my ($l,$r,$f,$b) = (0,0,0,0);

#main window
my $mw = MainWindow->new;
$mw->title("Asteroids");
my $canvas = $mw->Canvas(-bg => 'white', -width => 1000, -height => 400)->pack;
my @airplane = (140,120 , 220,145 , 140,170, 160,145 , 140,120);

#draw the plane for the first time
my $id = $canvas->createLine(@airplane);

#bind keys
$mw->bind('<KeyPress-Up>' => sub{$f = 1 } );
$mw->bind('<KeyPress-Down>' => sub{$b = 1 } );
$mw->bind('<KeyPress-Left>' => sub{$l = 1 } );
$mw->bind('<KeyPress-Right>' => sub{$r = 1 } );

$mw->bind('<KeyRelease-Up>' => sub{$f = 0 } );
$mw->bind('<KeyRelease-Down>' => sub{$b = 0 } );
$mw->bind('<KeyRelease-Left>' => sub{$l = 0 } );
$mw->bind('<KeyRelease-Right>' => sub{$r = 0 } );


$mw->bind('<KeyRelease-space>' => \&shoot);

#set up move loop
$mw->after(50, \&animate);

MainLoop;


sub move_left {
  $angle -= $angle_turn;
  &rotate;
}

sub move_right {
  $angle += $angle_turn;
  &rotate;
}

sub move_back {
my ($x1,$y1,$x2,$y2,$x3,$y3,$x4,$y4,$x5,$y5) = $canvas->coords($id);
  $x = ($x4 - $x2)*.35;
  $y = ($y4 - $y2)*.35;
}

sub move_foward {
my ($x1,$y1,$x2,$y2,$x3,$y3,$x4,$y4,$x5,$y5) = $canvas->coords($id);
  $x = ($x2 - $x4)*.35;
  $y = ($y2 - $y4)*.35;
}

#animates ship and controls acceleration and deceleration
sub animate {
#Check Keys
if($f == 1) {&move_foward;}
if($b == 1) {&move_back;}
if($l == 1) {&move_left;}
if($r == 1) {&move_right;}

unless($x ==0 && $y ==0) {$canvas->move($id,$x,$y);}
#apply friction
if($x != 0) {$x -= $x/20;}
if($y != 0) {$y -= $y/20;}

$mw->after(50, \&animate);
$x = int($x);
$y = int($y);

#handle shots fired
foreach(@shots_fired) {
my $id_shot = $_->{'shot'};
my $x_dir = $_->{'x'};
my $y_dir = $_->{'y'};
$canvas->move($id_shot,$x_dir,$y_dir);
}
if ($#shots_fired > 10) {$canvas->delete(@shots_fired[0]->{'shot'});shift @shots_fired;}
}
#support rotating

sub rotate {
  my (@x_prime,@y_prime,@final);

  #get cordinates
  my ($x1,$y1,$x2,$y2,$x3,$y3,$x4,$y4,$x5,$y5) = $canvas->coords($id);

  #set cordinates to seperate lists
  my @x_list = ($x1,$x2,$x3,$x4,$x5);
  my @y_list = ($y1,$y2,$y3,$y4,$y5);

  #in order to rotate we have to bring the cordinates to the origin first
  my ($offset_x,$offset_y) = ((($x4 + $x2)/2),(($y4 + $y2)/2));

  #moving each cordinates to origin before rotation
  for(my $i = 0; $i < 5; $i ++) {
    @x_list[$i] -= $offset_x;
    @y_list[$i] -= $offset_y;
  }

  #rotating each point about the origin
  for(my $i = 0; $i < 5;$i++) {
    my $x_p = $x_list[$i] * cos($angle ) - $y_list[$i] * sin($angle);
    my $y_p = $x_list[$i] * sin($angle ) + $y_list[$i] * cos($angle);
    push @x_prime, $x_p ;
    push @y_prime, $y_p ;
  }

  #move each cordinate back after rotation
  for(my $i = 0; $i < 5; $i ++) {
  @x_prime[$i] += $offset_x;
  @y_prime[$i] += $offset_y;
  }

  #put each point back into ordered pairs (x1,y1,x2,y2 ..etc)
  for(my $i = 0; $i < 5; $i ++) {
    push @final, $x_prime[$i], $y_prime[$i];
  }
  #clear old drawing
  $canvas->delete($id);

  #draw new ship
  $id = $canvas->createLine(@final);

  #clear everything out just in case
  $angle = 0;
  @final = ();
  @x_prime = ();
  @y_prime = ();
}

sub shoot {
  my ($x1,$y1,$x2,$y2,$x3,$y3,$x4,$y4,$x5,$y5) = $canvas->coords($id);
  my $id_shot = $canvas->createOval ($x2,$y2,$x2+3,$y2+1);
  my $x_dir = ($x2 - $x4)*.35;
  my $y_dir = ($y2 - $y4)*.35;
  push @shots_fired, { shot => $id_shot, x => $x_dir, y => $y_dir};
}
