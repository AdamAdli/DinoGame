`include "./DinoGameConstants.v"
`include "./Util.v"

module GameLogic(input clk, frameClk, resetn, jump, input [3:0] gameState, output reg `ubyte dinoY, 
    obs1X, obs1H, obs2X, obs2H, output reg collision, output [3:0] s_ones, s_tens, s_hundreds, s_thousands, s_tenthousands, s_hunthousands);
    
    reg `ubyte colObsL, colObsR, colObsT;
    reg [2:0] gameSpeed = 3'd1; // TODO: Adjust gamespeed.
    wire shouldJump = (jump && (dinoY == `groundTop - `dinoH));
    
    wire [3:0] c2;
    FrameSkipperClkAccurate obstacleFrameSkip(.clk(clk), .frameClk(frameClk), .resetn(resetn), .skipCount({1'b0, 3'd4 - gameSpeed}), .frame_count(c2));
    wire obsClk; //= (c2 == 0);

    ObsMoverTest obsMover(.clk(clk), .frameClk(frameClk), .resetn(resetn), .enable(gameState == `GAME_RUNNING), .pause(0), .moveClk(obsClk));

     /* Max score is 999999 (6 Hex Displays) and log2(999999) = 19.93 */
    GameScoreCounter gameScoreCounter(.clk(clk), .resetn(resetn), .gameState(gameState), .incrementEnable(obsClk), 
        .s_ones(s_ones), .s_tens(s_tens), .s_hundreds(s_hundreds), .s_thousands(s_thousands), .s_tenthousands(s_tenthousands), .s_hunthousands(s_hunthousands));

    wire `ubyte elevation;
    //DinoJumpCounter dinoJumper(.clk(clk), .frameClk(frameClk), .resetn(resetn), .jump(jump), .pause(0), .elevation(elevation));
    DinoStateJumpAutomationTest dinoJumper(.clk(clk), .frameClk(frameClk), .resetn(resetn), .enable(gameState == `GAME_RUNNING), .jump(jump), .pause(0), .elev(elevation));

    always @(posedge clk) begin
        if (!resetn || gameState == `GAME_MENU) begin
            dinoY <= `groundTop - `dinoH;
            obs1X <= 254;//32;
            obs1H <= `minObsH;
            obs2X <= 32;//254;
            obs2H <= `maxObsH;
            collision <= 0;
        end else begin
            if (frameClk) begin
                if (gameState == `GAME_RUNNING) begin
                    // Adjust gamespeed.
                    if (s_tenthousands >= 1 || s_hunthousands >= 1) gameSpeed <= 3;
                    else if (s_thousands < 1) gameSpeed <= 1;
                    else if (s_thousands >= 1) gameSpeed <= 2;
                end
            end
            if (gameState == `GAME_RUNNING) begin
                dinoY <= `groundTop - `dinoH - elevation;

                // Collision setup.
                if (obs1X < obs2X && obs1X >= `dinoLeft - `obsW) begin
                    colObsL = obs1X;
                    colObsR = obs1X + `obsW;
                    colObsT = `groundTop - obs1H;
                end else begin
                    colObsL = obs2X;
                    colObsR = obs2X + `obsW;
                    colObsT = `groundTop - obs2H;
                end

                // Check collisions.
                // Through elimination:
                collision <= 0;
                if ((colObsL < `dinoRight) && (colObsR > `dinoLeft) && (colObsT <= dinoY + `dinoH)) collision <= 1;
 
                // collision <= 0; //Commented THIS OUT (seems unnecessary?)
             
                /*if ((colObsL >= `dinoLeft && colObsL < `dinoRight) || (colObsR >= `dinoRight && colObsR - 1 < `dinoRight)) begin                 
                    //if (colObsT >= dinoY && colObsT < dinoY + `dinoH) collision <= 1; //OLD VERSION
                    if (colObsT <= dinoY + `dinoH) collision <= 1; // Nick's Maybe Working Ver?
                end*/

                // Update Obstacles.
                if (obsClk) begin
                    obs1X <= obs1X - 1;
                    obs2X <= obs2X - 1;
                end
            end
        end
    end
endmodule

module ObsMoverTest(input clk, frameClk, resetn, enable, input pause, output reg moveClk);
    reg [23:0] cycleCount;
    always @(posedge clk) begin
        if (!resetn) begin 
            cycleCount <= 0;
            moveClk <= 0;
        end else if (enable) begin
            if (cycleCount < 24'd86654) cycleCount <= cycleCount + 23'd1;
            else begin
                cycleCount <= 0;
                moveClk <= 1;
            end 
            if (moveClk) moveClk <= 0;
        end 
    end 
endmodule

/* f3: y=0.4008255 + (518.1582*t) - (1413.798*t*t)*/
module DinoStateJumpAutomation(input clk, frameClk, resetn, enable, jump, input pause, output reg `ubyte elev);
    reg [24:0] cycleCount;
    always @(posedge clk) begin
        if (!resetn) begin 
            cycleCount <= 0;
            elev <= 0;
        end else if (enable) begin
            if (cycleCount < 25'd18267044) cycleCount <= cycleCount + 25'd1;
            else if (jump) cycleCount <= 0;
            case (cycleCount)
                0: elev <= 0;
                25'd58003: elev <= 1;
                25'd155637: elev <= 2;
                25'd254341: elev <= 3;
                25'd354150: elev <= 4;
                25'd455104: elev <= 5;
                25'd557242: elev <= 6;
                25'd660607: elev <= 7;
                25'd765245: elev <= 8;
                25'd871202: elev <= 9;
                25'd978532: elev <= 10;
                25'd1087288: elev <= 11;
                25'd1197529: elev <= 12;
                25'd1309317: elev <= 13;
                25'd1422719: elev <= 14;
                25'd1537808: elev <= 15;
                25'd1654661: elev <= 16;
                25'd1773362: elev <= 17;
                25'd1894001: elev <= 18;
                25'd2016676: elev <= 19;
                25'd2141494: elev <= 20;
                25'd2268572: elev <= 21;
                25'd2398037: elev <= 22;
                25'd2530028: elev <= 23;
                25'd2664700: elev <= 24;
                25'd2802223: elev <= 25;
                25'd2942786: elev <= 26;
                25'd3086600: elev <= 27;
                25'd3233901: elev <= 28;
                25'd3384957: elev <= 29;
                25'd3540070: elev <= 30;
                25'd3699585: elev <= 31;
                25'd3863900: elev <= 32;
                25'd4033476: elev <= 33;
                25'd4208854: elev <= 34;
                25'd4390673: elev <= 35;
                25'd4579701: elev <= 36;
                25'd4776867: elev <= 37;
                25'd4983326: elev <= 38;
                25'd5200528: elev <= 39;
                25'd5430350: elev <= 40;
                25'd5675285: elev <= 41;
                25'd5938776: elev <= 42;
                25'd6225815: elev <= 43;
                25'd6544132: elev <= 44;
                25'd6906934: elev <= 45;
                25'd7340602: elev <= 46;
                25'd7917087: elev <= 47;
                25'd10407960: elev <= 46;
                25'd10984445: elev <= 45;
                25'd11418113: elev <= 44;
                25'd11780914: elev <= 43;
                25'd12099232: elev <= 42;
                25'd12386270: elev <= 41;
                25'd12649762: elev <= 40;
                25'd12894697: elev <= 39;
                25'd13124518: elev <= 38;
                25'd13341721: elev <= 37;
                25'd13548179: elev <= 36;
                25'd13745346: elev <= 35;
                25'd13934373: elev <= 34;
                25'd14116192: elev <= 33;
                25'd14291570: elev <= 32;
                25'd14461147: elev <= 31;
                25'd14625462: elev <= 30;
                25'd14784977: elev <= 29;
                25'd14940089: elev <= 28;
                25'd15091145: elev <= 27;
                25'd15238447: elev <= 26;
                25'd15382260: elev <= 25;
                25'd15522823: elev <= 24;
                25'd15660346: elev <= 23;
                25'd15795018: elev <= 22;
                25'd15927010: elev <= 21;
                25'd16056474: elev <= 20;
                25'd16183552: elev <= 19;
                25'd16308371: elev <= 18;
                25'd16431046: elev <= 17;
                25'd16551685: elev <= 16;
                25'd16670386: elev <= 15;
                25'd16787238: elev <= 14;
                25'd16902327: elev <= 13;
                25'd17015730: elev <= 12;
                25'd17127518: elev <= 11;
                25'd17237759: elev <= 10;
                25'd17346515: elev <= 9;
                25'd17453844: elev <= 8;
                25'd17559802: elev <= 7;
                25'd17664439: elev <= 6;
                25'd17767804: elev <= 5;
                25'd17869942: elev <= 4;
                25'd17970896: elev <= 3;
                25'd18070706: elev <= 2;
                25'd18169410: elev <= 1;
                25'd18267044: elev <= 0;
            endcase
        end 
    end
endmodule

module DinoStateJumpAutomationTest(input clk, frameClk, resetn, enable, jump, input pause, output reg `ubyte elev);
    reg [24:0] cycleCount;
    always @(posedge clk) begin
        if (!resetn) begin 
            cycleCount <= 25'd2192026;
            elev <= 0;
        end else if (enable) begin
            if (cycleCount < 25'd2192025) cycleCount <= cycleCount + 25'd1;
            else if (jump) cycleCount <= 0;
            case (cycleCount)
                0: elev <= 0;
                25'd6962: elev <= 1;
                25'd18678: elev <= 2;
                25'd30522: elev <= 3;
                25'd42499: elev <= 4;
                25'd54613: elev <= 5;
                25'd66870: elev <= 6;
                25'd79273: elev <= 7;
                25'd91830: elev <= 8;
                25'd104545: elev <= 9;
                25'd117424: elev <= 10;
                25'd130475: elev <= 11;
                25'd143703: elev <= 12;
                25'd157118: elev <= 13;
                25'd170726: elev <= 14;
                25'd184536: elev <= 15;
                25'd198559: elev <= 16;
                25'd212803: elev <= 17;
                25'd227279: elev <= 18;
                25'd242000: elev <= 19;
                25'd256978: elev <= 20;
                25'd272227: elev <= 21;
                25'd287763: elev <= 22;
                25'd303602: elev <= 23;
                25'd319762: elev <= 24;
                25'd336265: elev <= 25;
                25'd353132: elev <= 26;
                25'd370390: elev <= 27;
                25'd388066: elev <= 28;
                25'd406192: elev <= 29;
                25'd424805: elev <= 30;
                25'd443947: elev <= 31;
                25'd463665: elev <= 32;
                25'd484014: elev <= 33;
                25'd505059: elev <= 34;
                25'd526877: elev <= 35;
                25'd549560: elev <= 36;
                25'd573220: elev <= 37;
                25'd597994: elev <= 38;
                25'd624058: elev <= 39;
                25'd651637: elev <= 40;
                25'd681029: elev <= 41;
                25'd712647: elev <= 42;
                25'd747092: elev <= 43;
                25'd785289: elev <= 44;
                25'd828825: elev <= 45;
                25'd880865: elev <= 46;
                25'd950042: elev <= 47;
                25'd1248944: elev <= 46;
                25'd1318122: elev <= 45;
                25'd1370161: elev <= 44;
                25'd1413697: elev <= 43;
                25'd1451895: elev <= 42;
                25'd1486339: elev <= 41;
                25'd1517958: elev <= 40;
                25'd1547349: elev <= 39;
                25'd1574928: elev <= 38;
                25'd1600992: elev <= 37;
                25'd1625767: elev <= 36;
                25'd1649426: elev <= 35;
                25'd1672109: elev <= 34;
                25'd1693927: elev <= 33;
                25'd1714973: elev <= 32;
                25'd1735322: elev <= 31;
                25'd1755039: elev <= 30;
                25'd1774181: elev <= 29;
                25'd1792794: elev <= 28;
                25'd1810921: elev <= 27;
                25'd1828597: elev <= 26;
                25'd1845854: elev <= 25;
                25'd1862721: elev <= 24;
                25'd1879224: elev <= 23;
                25'd1895385: elev <= 22;
                25'd1911223: elev <= 21;
                25'd1926759: elev <= 20;
                25'd1942008: elev <= 19;
                25'd1956986: elev <= 18;
                25'd1971707: elev <= 17;
                25'd1986184: elev <= 16;
                25'd2000428: elev <= 15;
                25'd2014450: elev <= 14;
                25'd2028260: elev <= 13;
                25'd2041868: elev <= 12;
                25'd2055283: elev <= 11;
                25'd2068512: elev <= 10;
                25'd2081562: elev <= 9;
                25'd2094442: elev <= 8;
                25'd2107156: elev <= 7;
                25'd2119713: elev <= 6;
                25'd2132117: elev <= 5;
                25'd2144373: elev <= 4;
                25'd2156487: elev <= 3;
                25'd2168464: elev <= 2;
                25'd2180309: elev <= 1;
                25'd2192025: elev <= 0;
            endcase
        end 
    end
endmodule


/* f2: y=0.4008255+598.1582x-1413.798x^2
module DinoStateJumpAutomation(input clk, frameClk, resetn, jump, input pause, output reg `ubyte elev);
    reg [24:0] cycleCount;
    always @(posedge clk) begin
        if (!resetn) begin 
            cycleCount <= 0;
            elev <= 0;
        end else begin
            if (cycleCount < 25'd21104100) cycleCount <= cycleCount + 25'd1;
            else if (jump) cycleCount <= 0;
            case (cycleCount)
                0: elev <= 0;
                25'd50206: elev <= 1;
                25'd134532: elev <= 2;
                25'd219545: elev <= 3;
                25'd305261: elev <= 4;
                25'd391699: elev <= 5;
                25'd478876: elev <= 6;
                25'd566813: elev <= 7;
                25'd655529: elev <= 8;
                25'd745046: elev <= 9;
                25'd835385: elev <= 10;
                25'd926570: elev <= 11;
                25'd1018624: elev <= 12;
                25'd1111574: elev <= 13;
                25'd1205446: elev <= 14;
                25'd1300267: elev <= 15;
                25'd1396068: elev <= 16;
                25'd1492879: elev <= 17;
                25'd1590733: elev <= 18;
                25'd1689664: elev <= 19;
                25'd1789709: elev <= 20;
                25'd1890906: elev <= 21;
                25'd1993296: elev <= 22;
                25'd2096922: elev <= 23;
                25'd2201830: elev <= 24;
                25'd2308069: elev <= 25;
                25'd2415691: elev <= 26;
                25'd2524752: elev <= 27;
                25'd2635309: elev <= 28;
                25'd2747428: elev <= 29;
                25'd2861175: elev <= 30;
                25'd2976625: elev <= 31;
                25'd3093856: elev <= 32;
                25'd3212953: elev <= 33;
                25'd3334007: elev <= 34;
                25'd3457120: elev <= 35;
                25'd3582399: elev <= 36;
                25'd3709963: elev <= 37;
                25'd3839942: elev <= 38;
                25'd3972478: elev <= 39;
                25'd4107729: elev <= 40;
                25'd4245869: elev <= 41;
                25'd4387091: elev <= 42;
                25'd4531611: elev <= 43;
                25'd4679671: elev <= 44;
                25'd4831545: elev <= 45;
                25'd4987545: elev <= 46;
                25'd5148025: elev <= 47;
                25'd5313395: elev <= 48;
                25'd5484132: elev <= 49;
                25'd5660795: elev <= 50;
                25'd5844047: elev <= 51;
                25'd6034687: elev <= 52;
                25'd6233685: elev <= 53;
                25'd6442249: elev <= 54;
                25'd6661908: elev <= 55;
                25'd6894646: elev <= 56;
                25'd7143122: elev <= 57;
                25'd7411038: elev <= 58;
                25'd7703828: elev <= 59;
                25'd8030055: elev <= 60;
                25'd8404730: elev <= 61;
                25'd8859267: elev <= 62;
                25'd9489566: elev <= 63;
                25'd11664740: elev <= 62;
                25'd12295038: elev <= 61;
                25'd12749575: elev <= 60;
                25'd13124250: elev <= 59;
                25'd13450477: elev <= 58;
                25'd13743267: elev <= 57;
                25'd14011183: elev <= 56;
                25'd14259659: elev <= 55;
                25'd14492397: elev <= 54;
                25'd14712056: elev <= 53;
                25'd14920620: elev <= 52;
                25'd15119619: elev <= 51;
                25'd15310258: elev <= 50;
                25'd15493510: elev <= 49;
                25'd15670173: elev <= 48;
                25'd15840910: elev <= 47;
                25'd16006281: elev <= 46;
                25'd16166760: elev <= 45;
                25'd16322760: elev <= 44;
                25'd16474634: elev <= 43;
                25'd16622694: elev <= 42;
                25'd16767214: elev <= 41;
                25'd16908436: elev <= 40;
                25'd17046576: elev <= 39;
                25'd17181827: elev <= 38;
                25'd17314363: elev <= 37;
                25'd17444342: elev <= 36;
                25'd17571906: elev <= 35;
                25'd17697185: elev <= 34;
                25'd17820298: elev <= 33;
                25'd17941353: elev <= 32;
                25'd18060449: elev <= 31;
                25'd18177680: elev <= 30;
                25'd18293130: elev <= 29;
                25'd18406877: elev <= 28;
                25'd18518996: elev <= 27;
                25'd18629554: elev <= 26;
                25'd18738614: elev <= 25;
                25'd18846236: elev <= 24;
                25'd18952475: elev <= 23;
                25'd19057383: elev <= 22;
                25'd19161009: elev <= 21;
                25'd19263399: elev <= 20;
                25'd19364596: elev <= 19;
                25'd19464641: elev <= 18;
                25'd19563572: elev <= 17;
                25'd19661426: elev <= 16;
                25'd19758237: elev <= 15;
                25'd19854038: elev <= 14;
                25'd19948859: elev <= 13;
                25'd20042731: elev <= 12;
                25'd20135681: elev <= 11;
                25'd20227735: elev <= 10;
                25'd20318920: elev <= 9;
                25'd20409259: elev <= 8;
                25'd20498776: elev <= 7;
                25'd20587492: elev <= 6;
                25'd20675429: elev <= 5;
                25'd20762606: elev <= 4;
                25'd20849044: elev <= 3;
                25'd20934760: elev <= 2;
                25'd21019773: elev <= 1;
                25'd21104100: elev <= 0;
            endcase
        end 
    end
endmodule

module DinoStateJumpAutomationTest(input clk, frameClk, resetn, jump, input pause, output reg `ubyte elev);
    reg [24:0] cycleCount;
    always @(posedge clk) begin
        if (!resetn) begin 
            cycleCount <= 0;
            elev <= 0;
        end else begin
            if (cycleCount < 25'd2532468) cycleCount <= cycleCount + 25'd1;
            else if (jump) cycleCount <= 0;
            case (cycleCount)
                0: elev <= 0;
                25'd6026: elev <= 1;
                25'd16145: elev <= 2;
                25'd26346: elev <= 3;
                25'd36632: elev <= 4;
                25'd47005: elev <= 5;
                25'd57466: elev <= 6;
                25'd68018: elev <= 7;
                25'd78664: elev <= 8;
                25'd89406: elev <= 9;
                25'd100247: elev <= 10;
                25'd111189: elev <= 11;
                25'd122235: elev <= 12;
                25'd133389: elev <= 13;
                25'd144653: elev <= 14;
                25'd156032: elev <= 15;
                25'd167528: elev <= 16;
                25'd179145: elev <= 17;
                25'd190887: elev <= 18;
                25'd202759: elev <= 19;
                25'd214764: elev <= 20;
                25'd226908: elev <= 21;
                25'd239194: elev <= 22;
                25'd251629: elev <= 23;
                25'd264218: elev <= 24;
                25'd276967: elev <= 25;
                25'd289881: elev <= 26;
                25'd302968: elev <= 27;
                25'd316235: elev <= 28;
                25'd329689: elev <= 29;
                25'd343339: elev <= 30;
                25'd357193: elev <= 31;
                25'd371260: elev <= 32;
                25'd385552: elev <= 33;
                25'd400078: elev <= 34;
                25'd414852: elev <= 35;
                25'd429885: elev <= 36;
                25'd445192: elev <= 37;
                25'd460790: elev <= 38;
                25'd476694: elev <= 39;
                25'd492924: elev <= 40;
                25'd509501: elev <= 41;
                25'd526447: elev <= 42;
                25'd543789: elev <= 43;
                25'd561556: elev <= 44;
                25'd579781: elev <= 45;
                25'd598501: elev <= 46;
                25'd617758: elev <= 47;
                25'd637602: elev <= 48;
                25'd658091: elev <= 49;
                25'd679290: elev <= 50;
                25'd701280: elev <= 51;
                25'd724156: elev <= 52;
                25'd748036: elev <= 53;
                25'd773064: elev <= 54;
                25'd799422: elev <= 55;
                25'd827351: elev <= 56;
                25'd857167: elev <= 57;
                25'd889317: elev <= 58;
                25'd924451: elev <= 59;
                25'd963598: elev <= 60;
                25'd1008559: elev <= 61;
                25'd1063103: elev <= 62;
                25'd1138738: elev <= 63;
                25'd1399756: elev <= 62;
                25'd1475391: elev <= 61;
                25'd1529935: elev <= 60;
                25'd1574896: elev <= 59;
                25'd1614042: elev <= 58;
                25'd1649177: elev <= 57;
                25'd1681326: elev <= 56;
                25'd1711143: elev <= 55;
                25'd1739072: elev <= 54;
                25'd1765430: elev <= 53;
                25'd1790458: elev <= 52;
                25'd1814337: elev <= 51;
                25'd1837214: elev <= 50;
                25'd1859204: elev <= 49;
                25'd1880403: elev <= 48;
                25'd1900892: elev <= 47;
                25'd1920736: elev <= 46;
                25'd1939993: elev <= 45;
                25'd1958713: elev <= 44;
                25'd1976938: elev <= 43;
                25'd1994705: elev <= 42;
                25'd2012047: elev <= 41;
                25'd2028993: elev <= 40;
                25'd2045570: elev <= 39;
                25'd2061800: elev <= 38;
                25'd2077704: elev <= 37;
                25'd2093301: elev <= 36;
                25'd2108609: elev <= 35;
                25'd2123642: elev <= 34;
                25'd2138416: elev <= 33;
                25'd2152942: elev <= 32;
                25'd2167234: elev <= 31;
                25'd2181301: elev <= 30;
                25'd2195155: elev <= 29;
                25'd2208804: elev <= 28;
                25'd2222259: elev <= 27;
                25'd2235525: elev <= 26;
                25'd2248612: elev <= 25;
                25'd2261527: elev <= 24;
                25'd2274276: elev <= 23;
                25'd2286864: elev <= 22;
                25'd2299299: elev <= 21;
                25'd2311586: elev <= 20;
                25'd2323730: elev <= 19;
                25'd2335735: elev <= 18;
                25'd2347607: elev <= 17;
                25'd2359349: elev <= 16;
                25'd2370966: elev <= 15;
                25'd2382462: elev <= 14;
                25'd2393840: elev <= 13;
                25'd2405105: elev <= 12;
                25'd2416259: elev <= 11;
                25'd2427305: elev <= 10;
                25'd2438247: elev <= 9;
                25'd2449088: elev <= 8;
                25'd2459830: elev <= 7;
                25'd2470476: elev <= 6;
                25'd2481028: elev <= 5;
                25'd2491489: elev <= 4;
                25'd2501862: elev <= 3;
                25'd2512147: elev <= 2;
                25'd2522349: elev <= 1;
                25'd2532468: elev <= 0;
            endcase
        end 
    end
endmodule

/*
f1:0.4008255 + (498.1582*t) - (1673.798*t*t)
module DinoStateJumpAutomation(input clk, frameClk, resetn, jump, input pause, output reg `ubyte elev);
    reg [23:0] cycleCount;
    always @(posedge clk) begin
        if (!resetn) begin 
            cycleCount <= 0;
            elev <= 0;
        end else if (clk) begin
            if (cycleCount < 24'd14820690) cycleCount <= cycleCount + 23'd1;
            else if (jump) cycleCount <= 0;
            case (cycleCount)
                0: elev <= 0;
                24'd60386: elev <= 1;
                24'd162280: elev <= 2;
                24'd265621: elev <= 3;
                24'd370473: elev <= 4;
                24'd476903: elev <= 5;
                24'd584985: elev <= 6;
                24'd694799: elev <= 7;
                24'd806430: elev <= 8;
                24'd919972: elev <= 9;
                24'd1035527: elev <= 10;
                24'd1153205: elev <= 11;
                24'd1273128: elev <= 12;
                24'd1395429: elev <= 13;
                24'd1520257: elev <= 14;
                24'd1647773: elev <= 15;
                24'd1778161: elev <= 16;
                24'd1911623: elev <= 17;
                24'd2048387: elev <= 18;
                24'd2188711: elev <= 19;
                24'd2332889: elev <= 20;
                24'd2481257: elev <= 21;
                24'd2634203: elev <= 22;
                24'd2792178: elev <= 23;
                24'd2955715: elev <= 24;
                24'd3125445: elev <= 25;
                24'd3302130: elev <= 26;
                24'd3486703: elev <= 27;
                24'd3680325: elev <= 28;
                24'd3884474: elev <= 29;
                24'd4101079: elev <= 30;
                24'd4332745: elev <= 31;
                24'd4583132: elev <= 32;
                24'd4857680: elev <= 33;
                24'd5165115: elev <= 34;
                24'd5521179: elev <= 35;
                24'd5960562: elev <= 36;
                24'd6605840: elev <= 37;
                24'd8275236: elev <= 36;
                24'd8920514: elev <= 35;
                24'd9359897: elev <= 34;
                24'd9715961: elev <= 33;
                24'd10023396: elev <= 32;
                24'd10297943: elev <= 31;
                24'd10548331: elev <= 30;
                24'd10779997: elev <= 29;
                24'd10996602: elev <= 28;
                24'd11200751: elev <= 27;
                24'd11394373: elev <= 26;
                24'd11578946: elev <= 25;
                24'd11755631: elev <= 24;
                24'd11925361: elev <= 23;
                24'd12088898: elev <= 22;
                24'd12246873: elev <= 21;
                24'd12399819: elev <= 20;
                24'd12548187: elev <= 19;
                24'd12692365: elev <= 18;
                24'd12832689: elev <= 17;
                24'd12969453: elev <= 16;
                24'd13102915: elev <= 15;
                24'd13233303: elev <= 14;
                24'd13360819: elev <= 13;
                24'd13485647: elev <= 12;
                24'd13607948: elev <= 11;
                24'd13727871: elev <= 10;
                24'd13845549: elev <= 9;
                24'd13961104: elev <= 8;
                24'd14074646: elev <= 7;
                24'd14186277: elev <= 6;
                24'd14296091: elev <= 5;
                24'd14404173: elev <= 4;
                24'd14510603: elev <= 3;
                24'd14615455: elev <= 2;
                24'd14718796: elev <= 1;
                24'd14820690: elev <= 0;
            endcase
        end 
    end
endmodule

module DinoStateJumpAutomationTest(input clk, frameClk, resetn, jump, input pause, output reg `ubyte elev);
    reg [23:0] cycleCount;
    always @(posedge clk) begin
        if (!resetn) begin 
            cycleCount <= 0;
            elev <= 0;
        end else begin
            if (cycleCount < 24'd1778466) cycleCount <= cycleCount + 24'd1;
            else if (jump) cycleCount <= 0;
            case (cycleCount)
                0: elev <= 0;
                24'd7248: elev <= 1;
                24'd19475: elev <= 2;
                24'd31876: elev <= 3;
                24'd44458: elev <= 4;
                24'd57229: elev <= 5;
                24'd70199: elev <= 6;
                24'd83376: elev <= 7;
                24'd96772: elev <= 8;
                24'd110397: elev <= 9;
                24'd124263: elev <= 10;
                24'd138385: elev <= 11;
                24'd152775: elev <= 12;
                24'd167451: elev <= 13;
                24'd182430: elev <= 14;
                24'd197732: elev <= 15;
                24'd213379: elev <= 16;
                24'd229394: elev <= 17;
                24'd245805: elev <= 18;
                24'd262644: elev <= 19;
                24'd279945: elev <= 20;
                24'd297749: elev <= 21;
                24'd316102: elev <= 22;
                24'd335059: elev <= 23;
                24'd354684: elev <= 24;
                24'd375051: elev <= 25;
                24'd396253: elev <= 26;
                24'd418401: elev <= 27;
                24'd441636: elev <= 28;
                24'd466133: elev <= 29;
                24'd492126: elev <= 30;
                24'd519926: elev <= 31;
                24'd549972: elev <= 32;
                24'd582917: elev <= 33;
                24'd619809: elev <= 34;
                24'd662536: elev <= 35;
                24'd715262: elev <= 36;
                24'd792694: elev <= 37;
                24'd993020: elev <= 36;
                24'd1070452: elev <= 35;
                24'd1123178: elev <= 34;
                24'd1165905: elev <= 33;
                24'd1202797: elev <= 32;
                24'd1235742: elev <= 31;
                24'd1265788: elev <= 30;
                24'd1293588: elev <= 29;
                24'd1319580: elev <= 28;
                24'd1344078: elev <= 27;
                24'd1367312: elev <= 26;
                24'd1389461: elev <= 25;
                24'd1410663: elev <= 24;
                24'd1431030: elev <= 23;
                24'd1450655: elev <= 22;
                24'd1469611: elev <= 21;
                24'd1487965: elev <= 20;
                24'd1505769: elev <= 19;
                24'd1523070: elev <= 18;
                24'd1539909: elev <= 17;
                24'd1556320: elev <= 16;
                24'd1572335: elev <= 15;
                24'd1587982: elev <= 14;
                24'd1603284: elev <= 13;
                24'd1618263: elev <= 12;
                24'd1632939: elev <= 11;
                24'd1647329: elev <= 10;
                24'd1661451: elev <= 9;
                24'd1675317: elev <= 8;
                24'd1688942: elev <= 7;
                24'd1702338: elev <= 6;
                24'd1715515: elev <= 5;
                24'd1728485: elev <= 4;
                24'd1741256: elev <= 3;
                24'd1753838: elev <= 2;
                24'd1766239: elev <= 1;
                24'd1778466: elev <= 0;
            endcase
        end 
    end
endmodule*/

module DinoJumpCounter(input clk, frameClk, resetn, jump, input pause, output reg signed `ubyte elevation);
    parameter MAX = 36;
    reg signed `ubyte accel;
    always @(posedge clk) begin
        if (!resetn) begin 
            elevation <= 0;
            accel <= 14;
        end else if (1) begin
            $display("%t updating dinoJump elevation: %d accel: %d", $time, elevation, accel);
            if (accel > 0) begin
                if (elevation + accel >= MAX) begin
                    if (elevation + (accel / 2) >= MAX) begin
                        if (elevation + (accel / 4) >= MAX) begin
                            if (elevation + (accel / 8) >= MAX) begin
                                elevation <= MAX;
                                accel <= -accel;
                            end else begin
                                elevation <= elevation + (accel / 8);
                            end
                        end else begin
                            elevation <= elevation + (accel / 4);
                        end
                    end else begin
                        elevation <= elevation + (accel / 2);
                    end
                end else begin
                    elevation <= elevation + accel;
                end
                accel <= accel / 2;
            end else if (accel == 0) begin
                if (!(jump && (elevation == 0))) accel <= -1;
            end else if (accel < 0) begin
                if (elevation + accel <= 0) begin
                    if (elevation + (accel / 2) <= 0) begin
                        if (elevation + (accel / 4) <= 0) begin
                            if (elevation + (accel / 8) <= 0) begin
                                elevation <= 0;
                                accel <= 0;
                            end else begin
                                elevation <= elevation + (accel / 8);
                            end
                            accel <= accel / 12;
                        end else begin
                            elevation <= elevation + (accel / 4);
                        end
                    end else begin
                        elevation <= elevation + (accel / 2);
                    end
                end else begin
                    elevation <= elevation + accel;
                end
                accel <= accel * 2;
            end
            if (jump && (elevation == 0)) accel <= 14;
            /*if (elevation + accel >= MAX) begin
                if (elevation + (accel / 2) >= MAX) begin
                    if (elevation + (accel / 4) >= MAX) begin
                        if (elevation + (accel / 8) >= MAX) begin
                            elevation <= MAX;
                            accel <= -accel;
                        end else begin
                            elevation <= elevation + (accel / 8);
                        end
                    end else begin
                        elevation <= elevation + (accel / 4);
                    end
                end else begin
                    elevation <= elevation + (accel / 2);
                end
            end else if (elevation + accel <= 0) begin
                elevation <= 0;
                accel <= 0;
            end else begin
                elevation <= elevation + accel;
            end*/
        end 
    end
endmodule