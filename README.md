# Soldat Tactical Trench War (TTW)

A standalone server for the 2D Side Scrolling Action Shooter game [Soldat](https://www.soldat.pl), configured to run the Tactical Trench War game mode.

## TTW Specific

Soldat is written in Pascal, and utilizes Pascal Script for its server scripting, which is compiled at server initialization. The code base specifically for the TTW Game Mode can be found within the ./Scripts directory. For an overview on the gameplay of the mode, refer to the [TTW Wiki article](https://wiki.soldat.pl/index.php/TTW).

* Gather_new - Handles the settings for server matchmaking and relevant commands
* New TWW - Houses the core code for the TTW game mode
