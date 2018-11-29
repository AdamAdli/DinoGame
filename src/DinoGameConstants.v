`ifndef DINO_GAME_CONSTANTS
    `define ubyte [7:0] 
    `define uint [31:0]

    /* Dimensions */
    `define xMAX 159
    `define yMAX 119
    // `define dinoX 16
    // `define dinoW 10
    `define dinoLeft 15
    `define dinoRight 25
    `define dinoH 12
    `define obsW 12
    `define minObsH 7
    `define maxObsH 14

    `define groundTop 105

    /* Colors */
    `define colBG 3'b011
    `define colDino 3'b010
    `define colDinoTransparentMask 3'b010
    `define colObs1 3'b100
    `define colObs2 3'b101
    `define colGrnd 3'b110

    /* Game States */
    `define GAME_MENU           4'b0000
    `define GAME_MENU_WAIT      4'b0001
    `define GAME_RUNNING        4'b0011
    `define GAME_RUNNING_WAIT   4'b0111
    `define GAME_PAUSE          4'b1111
    `define GAME_PAUSE_WAIT     4'b1011
    `define GAME_OVER           4'b0010
    `define GAME_OVER_WAIT_1    4'b0110
    `define GAME_OVER_WAIT_2    4'b0100  // We split this to avoid race issue between flipping bits causing weird momentary states.
    `define DINO_GAME_CONSTANTS  
`endif
