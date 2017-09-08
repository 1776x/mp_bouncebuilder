// Version 1.0


#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

main() {

    // thread trigger();
    precacheMenu("clientcmd");
    precacheMenu("move_main");
    precacheMenu("move_cp");
    precacheMenu("menu_small_s");
    precacheMenu("menu_small_s");
    precacheMenu("menu_small_m");
    precacheMenu("menu_small_l");

    precacheShader("welcome_logo");
    precacheShader("radiant_arrow");
    precacheShader("bindhelp");
    
    level.types = [];
    level.types[0] = "bounce";
    level.types[1] = "plate";

    level.bounces = [];
    level.plates = [];

    level.distances = [];
    level.distances[0] = 1;
    level.distances[1] = 5;
    level.distances[2] = 10;
    level.distances[3] = 50;
    level.distances[4] = 100;
    level.distances[5] = 500;

    level.angles = [];
    level.angles[0] = 1;
    level.angles[1] = 5;
    level.angles[2] = 45;
    level.angles[3] = 90;

    level.axis = [];
    level.axis[0] = "X";
    level.axis[1] = "Y";
    level.axis[2] = "Z";

    level.colors[0] = (0, 1, 0);            level.circlefx[0] = loadfx("bounce/radiant_arrow_green");
    level.colors[1] = (1, 0, 0);            level.circlefx[1] = loadfx("bounce/radiant_arrow_red");
    level.colors[2] = (1, 1, 1);            level.circlefx[2] = loadfx("bounce/radiant_arrow_white");
    level.colors[3] = (0, 1, 1);            level.circlefx[3] = loadfx("bounce/radiant_arrow_cyan");
    level.colors[4] = (1, 0.549, 0);        level.circlefx[4] = loadfx("bounce/radiant_arrow_orange");
    level.colors[5] = (0.502, 0, 0.502);    level.circlefx[5] = loadfx("bounce/radiant_arrow_purple");
    level.colors[6] = (1, 1, 0);            level.circlefx[6] = loadfx("bounce/radiant_arrow_yellow");
    level.colors[7] = (1, 1, 0);            level.circlefx[7] = loadfx("bounce/radiant_arrow_purplewhite");

    thread initBounces();
    thread onPlayerConnect();



    setdvar("r_specularcolorscale", "1");
    setdvar("compassmaxrange", "2000");
    setdvar("bg_falldamageminheight", "9998");
    setdvar("bg_falldamagemaxheight", "9999");
    setdvar("jump_slowdownenable", "0");
    setdvar("player_sprintcamerabob", "0");
    setdvar("player_sprinttime", "12.8");
    setdvar("sv_cheats", 1);
}

initBounces() {
    for (i = 1; i < 1024; i++) {
        ent = getEnt("Bounce" + i, "targetname");
        if (!IsDefined(ent)) continue;
        bounce = [];
        bounce["ent"] = ent;
        bounce["origin"] = ent.origin;
        bounce["angle"] = (0,0,0);
        level.bounces[level.bounces.size + 1] = bounce;
    }

    for (i = 1; i < 1024; i++) {
        ent = getEnt("Plat" + i, "targetname");
        if (!IsDefined(ent)) continue;
        plates = [];
        plates["ent"] = ent;
        plates["origin"] = ent.origin;
        plates["angle"] = (0,0,0);

        level.plates[level.plates.size + 1] = plates;
    }
}

/*
==============================================================
                    Moving/Rotaing Bounces
==============================================================
 */

/**
 * Moves an object
 *
 * This function moves a bounce or a plate to a given direction
 * Directions are: FORWARD, BACKWARD, LEFT, RIGHT, UP, DOWN
 * 
 * @param   int     obj_number  Number of the object 
 * @param   int     units       Units to Move
 * @param   string  orientation Orientation (see text above)
 * @param   string  type        Type of the object (bounce, plate, ...)
 */
moveObject(bounce_number, units, orientation, type) {
    self endon("disconnect");

    obj = getObject(int(bounce_number), type);
    if (!isDefined(obj)) return;

    obj["ent"] NotSolid();

    units = int(units);
    movetime = getMoveTime(units);
    self destroyfx();

    self addAction(obj["ent"], obj["ent"].origin, obj["angle"], self.selected, bounce_number);

    switch (orientation) {
        case "LEFT":
            obj["ent"] moveY(units * (-1), movetime["time"], movetime["accel"], movetime["accel"]);
            break;
        case "RIGHT":
            obj["ent"] moveY(units, movetime["time"], movetime["accel"], movetime["accel"]);
            break;
        case "FORWARD":
            obj["ent"] moveX(units, movetime["time"], movetime["accel"], movetime["accel"]);
            break;
        case "BACKWARD":
            obj["ent"] moveX(units * (-1), movetime["time"], movetime["accel"], movetime["accel"]);
            break;
        case "UP":
            obj["ent"] moveZ(units, movetime["time"], movetime["accel"], movetime["accel"]);
            break;
        case "DOWN":
            obj["ent"] moveZ(units * (-1), movetime["time"], movetime["accel"], movetime["accel"]);
            break;
        default:
            IPrintLn("nothing todo here");
    }

    obj["ent"] waittill("movedone");
    self fxforBounce();
    obj["ent"] Solid();
}

/**
 * Rotate Bounce/Plate
 *
 * Rotates a bounce in any given axis.
 * AXIS are X,Y and Z
 *
 * @param   int     obj_number  Number of the object 
 * @param   int     units       Units to Move
 * @param   string  orientation Orientation (see text above)
 * @param   string  type        Type of the object (bounce, plate, ...)
 */
rotateObject(obj_number, units, orientation, type) {
    obj = getObject(int(obj_number), type);
    if (!isDefined(obj)) return;
    units = int(units);

    self addAction(obj["ent"], obj["ent"].origin, obj["angle"], type, obj_number);
    switch (orientation) {
        case "X":
            obj["ent"] rotateRoll(units, 1, 0.5, 0.5);
            newangle =  (0,0,units);
            break;
        case "Y":
            obj["ent"] rotatePitch(units, 1, 0.5, 0.5);
            newangle =  (units,0,0);
            break;
        case "Z":
            obj["ent"] rotateYaw(units, 1, 0.5, 0.5);
            newangle =  (0,units,0);
            break;
        default:
            newangle = (0,0,0);
            break;
    }

    if(type == "plate"){
        level.plates[obj_number]["angle"] = obj["angle"] + newangle;
    }else if(type == "bounce"){
        level.bounces[obj_number]["angle"] = obj["angle"] + newangle;
    }
    obj["ent"] waittill("rotatedone");
}

/**
 * Places an object
 * 
 * Moves the object to the player origin
 * 
 * @param   int     obj_number  Number of the object 
 * @param   string  type        Type of the object (bounce, plate, ...)
 */
placeObject(obj_number, type) {
    self endon("disconnect");

    obj = getObject(int(obj_number), type);
    if (!isDefined(obj)) return;

    obj["ent"] NotSolid();

    origin = self.origin;
    origin = (round(origin[0],0), round(origin[1],0), round(origin[2],0));

    self destroyfx();

    self addAction(obj["ent"], obj["ent"].origin, obj["angle"], type, obj_number);

    obj["ent"] moveTo(origin, 1, 0.5, 0.5);
    obj["ent"] waittill("movedone");

    self fxforBounce();
    count = 0;
    if (self.selected == "bounce") {
        while (Distance2D(origin, obj["ent"].origin) < 50) {
            if (count > 4 && count % 4 == 0) {
                self IPrintLnBold("Can't get solid if you block me");
            }
            count++;
            origin = self.origin;
            wait 0.5;

        }
    }
    obj["ent"] Solid();
}

/*
==============================================================
                Restoring Bounces/Plates
==============================================================
 */

/**
 * Restores a bounce
 *
 * Sets the origin of a bounce to the default origin
 *
 * @param   int     obj_number  Number of the object 
 * @param   string  type        Type of the object (bounce, plate, ...)
 */
restoreBounce(obj_number, type) {
    obj = getObject(int(obj_number), type);
    if (!isDefined(obj)) return;

    self addAction(obj["ent"], obj["ent"].origin, obj["angle"], type, obj_number);

    obj["ent"] moveTo(obj["origin"], 1, 0.5, 0.5);
    obj["ent"] rotateTo((0, 0, 0), 1, 0.5, 0.5);

    obj["ent"] waittill("movedone");
    self destroyfx();
    self fxforBounce();
}

/**
 * Restores the bounce angle
 * 
 * Sets the angle of the object to (0,0,0)
 * 
 * @param   int     obj_number  Number of the object 
 * @param   string  type        Type of the object (bounce, plate, ...)
 */
restoreAngles(obj_number, type) {
    obj = getObject(int(obj_number), type);
    if (!isDefined(obj)) return;
    obj["ent"] rotateTo((0, 0, 0), 1, 0.5, 0.5);
    obj["ent"] waittill("rotatedone");

    if(type == "plate"){
        level.plates[obj_number]["angle"] = (0,0,0);
    }else if(type == "bounce"){
        level.bounces[obj_number]["angle"] = (0,0,0);
    }

    self addAction(obj["ent"], obj["ent"].origin, obj["angle"], type, obj_number);

}

/**
 * Resets the self.forcerestore variable
 * 
 * Resets the variable to false after 3 seconds
 */
resetForceVariable() {
    self endon("restoreDone");

    for (i = 3; i > 0; i--) {
        self IPrintLn("Restoreall will be disabled in ^1" + i + "^7seconds");
        wait 1;
    }
    self IPrintLn("restoreAll disabled");
    self.forcerestore = false;
}

/**
 * Restores all objects
 * 
 * Resets the angle and the origin of all bounces to their defaults
 * It also has a security check to avoid accidentally restore fails
 */
restoreAll() {
    if (!self.forcerestore) {
        self IPrintLnBold("^1!!!");
        self IPrintLnBold("Are you sure that you want to restore all bounces?");
        self IPrintLnBold("If yes, press this button again in the next 3 seconds");
        self IPrintLnBold("^1!!!");
        self.forcerestore = true;
        self thread resetForceVariable();
        return;
    } else {
        self notify("restoreDone");
        self.forcerestore = false;
    }
    for (i = 1; i <= level.bounces.size; i++) {
        level.bounces[i]["ent"] moveTo(level.bounces[i]["origin"], 1, 0.5, 0.5);
        level.bounces[i]["ent"] rotateTo((0, 0, 0), 1, 0.5, 0.5);
    }
    for (i = 1; i <= level.plates.size; i++) {
        level.plates[i]["ent"] moveTo(level.plates[i]["origin"], 1, 0.5, 0.5);
        level.plates[i]["ent"] rotateTo((0, 0, 0), 1, 0.5, 0.5);
    }
    wait 1;
    players = getEntArray("player", "classname");
    for (i = 0; i < players.size; i++) {
        players[i] destroyfx();
        players[i] fxforBounce();
    }
}

/*
==============================================================
                Changing selected values
==============================================================
 */

/**
 * Changes the angle value
 * 
 * This functions loops through the different angles (0,10,45, ...)
 */
changeAngle() {
    self endon("disconnect");

    self.lastangle++;
    if (self.lastangle >= level.angles.size) {
        self.lastangle = 0;
    }

    self.hud["anglehud"] SetValue(level.angles[self.lastangle]);
}

/**
 * Changes the distance value
 * 
 * This functions loops through the different distances (0,1,5,10,50,100,500)
 */
changeDistance() {
    self endon("disconnect");

    self.lastdistance++;
    if (self.lastdistance >= level.distances.size) {
        self.lastdistance = 0;
    }

    self.hud["distancehud"] SetValue(level.distances[self.lastdistance]);

    self IPrintLn("^1Distance set to:" + level.distances[self.lastdistance]);
}

/**
 * Changes the object type
 * 
 * Changes the object type (bounce, plate,  ...)
 * @param   string  type        Type of the object (bounce, plate, ...)
 */
changeType(type) {
    self endon("disconnect");
    
    for(i = 0; i < level.types.size; i++){
        if(level.types[i] == type){
           self.selected = type;
           break;
        }
    }
    self updateHud(self getSelection());
}

/**
 * Changes the axis value
 * 
 * This functions loops through the different axis (x,y,z)
 */
changeAxis() {
    self endon("disconnect");

    self.lastaxis++;
    if (self.lastaxis >= level.axis.size) {
        self.lastaxis = 0;
    }
    self IPrintLn("^1Axis was set to " + level.axis[self.lastaxis]);
}

/*
==============================================================
                Change Selections
==============================================================
 */

/**
 * Select the next/prev bounce
 * 
 * @param   string  action prev/next
 */
selectBounce(action) {
    self endon("disconnect");

    if (action == "prev") {
        if (self.selected == "bounce") {
            self.bouncenumber--;
        } else if (self.selected == "plate")
            self.platenumber--;
    } else if (action == "next") {
        if (self.selected == "bounce")
            self.bouncenumber++;
        else if (self.selected == "plate")
            self.platenumber++;
    }

    if (self.bouncenumber > level.bounces.size)
        self.bouncenumber = 1;

    if (self.platenumber > level.plates.size)
        self.platenumber = 1;

    if (self.bouncenumber < 1)
        self.bouncenumber = level.bounces.size;

    if (self.platenumber < 1)
        self.platenumber = level.plates.size;

    self updateHud(self getSelection());
    self destroyfx();
    self fxforBounce();
}

/**
 * Select by looking
 * 
 * Select an object by looking
 */
selectByLooking() {
    self endon("disconnect");

    if (self getStance() == "prone")
        eye = self.origin + (0, 0, 11);
    else if (self getStance() == "crouch")
        eye = self.origin + (0, 0, 40);
    else
        eye = self.origin + (0, 0, 60);

    start = eye;
    end = start + vector_scale(anglestoforward(self getPlayerAngles()), 999999);
    trace = bulletTrace(start, end, false, self);
    ent = trace["entity"];
    if (!isDefined(ent)) {
        IPrintLn("^1Nothing found");
        return;
    }
    for (i = 1; i <= level.bounces.size; i++) {
        if (checkSameVector(level.bounces[i]["ent"].origin, ent.origin)) {
            self.selected = "bounce";
            self.bouncenumber = i;
            self updateHud(self.bouncenumber);
            self destroyfx();
            self fxforBounce();
            return;
        }
    }
    for (i = 1; i <= level.plates.size; i++) {
        if (checkSameVector(level.plates[i]["ent"].origin, ent.origin)) {
            self.selected = "plate";
            self.platenumber = i;
            self updateHud(self.platenumber);
            self destroyfx();
            self fxforBounce();
            return;
        }
    }
}

/*
==============================================================
                History Functions
==============================================================
 */
addAction(ent, origin, angle, type, number) {
    history_entry = spawnStruct();
    history_entry.ent = ent;
    history_entry.origin = origin;
    history_entry.angle = angle;
    history_entry.type = type;
    history_entry.number = number;
    self.history[self.history.size] = history_entry;
}

undoAction() {
    self destroyfx();

    if (self.history.size < 1){
        self IPrintLn("Nothing to undo");
        return;
    }

    entry = self.history[self.history.size - 1];
    if(!isDefined(entry) || !isDefined(entry.ent) || !isDefined(entry.origin)) return;
    entry.ent MoveTo(entry.origin, 1, 0.5, 0.5);
    entry.ent RotateTo(entry.angle, 1, 0.5, 0.5);

    if(entry.type == "plate"){
        level.plates[entry.number]["angle"] = entry.angle;
    }else if(entry.type == "bounce"){
        level.bounces[entry.number]["angle"] = entry.angle;
    }


    self IPrintLn("^1[UNDO]^7" + entry.type + " " + entry.number);
    wait 1;
    self fxforBounce();

    newhist = [];
    for (i = 0; i < self.history.size - 1; i++) {
        newhist[i] = self.history[i];
    }
    self.history = newhist;
}

/*
==============================================================
                Utillity Functions
==============================================================
 */

getMoveTime(number) {
    val = [];
    if (number >= 100) {
        val["time"] = 1;
        val["accel"] = 0.5;
    } else if (number >= 10) {
        val["time"] = 1;
        val["accel"] = 0.25;
    } else {
        val["time"] = 0.25;
        val["accel"] = 0;
    }
    return val;
}

checkSameVector(a, b) {
    if (a[0] != b[0]) return false;
    if (a[1] != b[1]) return false;
    if (a[2] != b[2]) return false;
    return true;
}

updateHud(obj_number) {
    color = "^2";
    if (self.selected == "plate") color = "     ^3";
    self.hud["selecthud"] setText("Selection: " + color + self.selected + "^7 " + obj_number);
}

getObject(id, type) {
    if (type == "bounce") {
        if (isDefined(level.bounces[id])) {
            return level.bounces[id];
        }
    } else if (type == "plate") {
        if (isDefined(level.plates[id])) {
            return level.plates[id];
        }
    }
    return;
}

getVectorFromString(val) {
    substring = GetSubStr(val, 1, val.size - 1);
    parts = strtok(substring, ",");
    if (parts.size != 3)return (0, 0, 0);
    setDvar("tmp", parts[0]);
    x = GetDvarFloat("tmp");
    setDvar("tmp", parts[1]);
    y = GetDvarFloat("tmp");
    setDvar("tmp", parts[2]);
    z = GetDvarFloat("tmp");
    return (x, y, z);
}

getSelection() {
    self endon("disconnect");

    if (self.selected == "bounce") {
        return self.bouncenumber;
    } else if (self.selected == "plate") {
        return self.platenumber;
    } else {
        return 1;
    }
}


pow(x, n){
	if(n == 0){
		return 1;
	}
	orig = x;
	for(i = 1; i < n; i++){
		x = x * orig;
	}
	return x;
}

round(x, n) {
    x = x * pow(10, n);
    x = x + 0.5;
    x = floor(x) / pow(10, n);

    return x;
}

/*
==============================================================
                Dumping and Restoring Bounces
==============================================================
 */

cod2radiantAngle(angle){
    newangle = (-1,-1,-1) *  (angle[2], angle[0], angle[1]);
    return newangle;
}

radiant2codAngle(angle){
    newangle = (-1,-1,-1) * (angle[1], angle[2], angle[0]);
    return newangle;
}

saveProject() {
    self IPrintLnBold("Please wait a bit ...");
    for (i = 1; i <= level.bounces.size; i++) {
        self setClientDvar("zzz_bounce_" + i, level.bounces[i]["ent"].origin + "#" + cod2radiantAngle(level.bounces[i]["ent"].angles));
        LogPrint("Bounce " + i + " : " + level.bounces[i]["ent"].origin + " " + cod2radiantAngle(level.bounces[i]["ent"].angles) + "\n");
        wait 0.05;
    }
    for (i = 1; i <= level.plates.size; i++) {
        self setClientDvar("zzz_plate_" + i, level.plates[i]["ent"].origin + "#" + cod2radiantAngle(level.plates[i]["ent"].angles));
        LogPrint("Plate " + i + " : " + level.plates[i]["ent"].origin + " " + cod2radiantAngle(level.plates[i]["ent"].angles) + "\n");
        wait 0.05;
    }

    self IPrintLnBold("... done");
}

restoreProject() {
    //self clientcmd("setu tmp (0, 0, 0)#(0, 0, 0)");
    wait 1;
    //self clientCmd("setfromdvar tmp zzz_bounce_" + 1);
    wait 1;
    self destroyfx();
    for (i = 1; i <= level.bounces.size; i++) {
        //self clientCmd("setfromdvar tmp zzz_bounce_" + i);
		bounce = getDvar("zzz_bounce_"+i);
        wait 0.08;
		//bounce = self getuserinfo("tmp"); //getdvar("zzz_bounce_"+i);

        if (bounce == "")continue;

        text_parts = strtok(bounce, "#");
        if (text_parts.size != 2)continue;

        origin_vector = getVectorFromString(text_parts[0]);
        angle_vector = getVectorFromString(text_parts[1]);

        obj = getObject(i, "bounce");
        if (!isDefined(obj)) continue;
        obj["ent"] moveTo(origin_vector, 1, 0.5, 0.5);
        obj["ent"] rotateTo(radiant2codAngle(angle_vector) , 1, 0.5, 0.5);
    }

    wait 1;

    for (i = 1; i <= level.plates.size; i++) {
        wait 0.08;
        bounce = getDvar("zzz_plate_"+i);
        if (bounce == "")continue;

        text_parts = strtok(bounce, "#");
        if (text_parts.size != 2)continue;

        origin_vector = getVectorFromString(text_parts[0]);
        angle_vector = getVectorFromString(text_parts[1]);

        obj = getObject(i, "plate");
        if (!isDefined(obj)) continue;
        obj["ent"] moveTo(origin_vector, 1, 0.5, 0.5);
        obj["ent"] rotateTo(radiant2codAngle(angle_vector), 1, 0.5, 0.5);
    }
    wait 1;
    self fxforBounce();
}

/*
==============================================================
                Player related Stuff
==============================================================
 */

handleResponse() {
    self endon("disconnect");

    while (true) {
        self waittill("menuresponse", x, y);

        tok = strTok(y, ":");
        if (tok.size < 2) continue;
        switch (tok[0]) {
            case "move":
                if (tok.size != 5) continue;
                //move:4:1:RIGHT:bounce
                if (tok[1] == "x") {
                    tok[1] = self getSelection();
                    tok[4] = self.selected;
                }
                if (tok[2] == "x") {
                    tok[2] = level.distances[self.lastdistance];
                }
                self moveObject(tok[1], tok[2], tok[3], tok[4]);
                break;
            case "rotate":
                if (tok.size != 5) continue;
                //rotate:4:1:X:bounce
                if (tok[1] == "x") {
                    tok[1] = self getSelection();
                    tok[4] = self.selected;
                }
                if (tok[2] == "x") {
                    tok[2] = level.angles[self.lastangle];
                    tok[3] = level.axis[self.lastaxis];
                }
                self rotateObject(tok[1], tok[2], tok[3], tok[4]);
                break;
            case "rotateleft":
                if (tok.size != 5) continue;
                //rotate:4:1:X:bounce
                if (tok[1] == "x") {
                    tok[1] = self getSelection();
                    tok[4] = self.selected;
                }
                if (tok[2] == "x") {
                    tok[2] = level.angles[self.lastangle];
                    tok[3] = level.axis[self.lastaxis];
                }
                self rotateObject(tok[1], (-1) * tok[2], tok[3], tok[4]);
                break;
            case "restore":
                if (isDefined(tok[2]) && tok[2] == "x" && isDefined(tok[3])) {
                    tok[2] = self getSelection();
                    tok[3] = self.selected;
                }
                if (tok[1] == "bounce" && tok.size == 4) {
                    self restoreBounce(tok[2], tok[3]);
                } else if (tok[1] == "angle" && tok.size == 4) {
                    restoreAngles(tok[2], tok[3]);
                } else if (tok[1] == "all" && tok.size == 2) {
                    restoreAll();
                }
                break;
            case "place":
                if (tok[1] == "x") {
                    tok[1] = self getSelection();
                    tok[2] = self.selected;
                }
                //placeObject:4:bounce::
                self placeObject(tok[1], tok[2]);
                break;
            case "select":
                if (tok[1] == "prev" || tok[1] == "next" || (int(tok[1]) >= 1 && int(tok[1]) <= 50)) {
                    selectBounce(tok[1]);
                } else if (tok[1] == "eye") {
                    self selectbylooking();
                }
                break;
            case "change":
                if (tok[1] == "type" && tok.size == 3) {
                    self changeType(tok[2]);
                } else if (tok[1] == "axis" && tok.size == 2) {
                    self changeAxis();
                } else if (tok[1] == "angle" && tok.size == 2) {
                    self changeAngle();
                } else if (tok[1] == "distance" && tok.size == 2) {
                    self changeDistance();
                }
                break;
            case "project":
                if (tok[1] == "restore") {
                    self restoreProject();
                } else if (tok[1] == "save") {
                    self saveProject();
                }
                break;
            case "undo":
                self undoAction();
                break;
            case "fun":
                directions = [];
                directions[0] = "UP";
                directions[1] = "DOWN";
                directions[2] = "LEFT";
                directions[3] = "RIGHT";
                directions[4] = "FORWARD";
                directions[5] = "BACKWARD";
                for (i = 1; i <= level.plates.size; i++) {
                    self thread moveObject(i, 250 * i, directions[i % directions.size], "plate");
                }
                for (i = 1; i <= level.bounces.size; i++) {
                    self thread moveObject(i, 250 * i, directions[i % directions.size], "bounce");
                }
                break;
            case "fun2":
                self fun2();
                break;
            case "order":
            	for(i = 1; i <= level.bounces.size; i++){
            		level.bounces[i]["ent"] moveTo((i * 250, 0, 0), .5, .05, .05);
            	}
                for(i = 1; i <= level.plates.size; i++){
                    level.plates[i]["ent"] moveTo((i * 250, 300, 0), .5, .05, .05);
                }
            	break;
        }
    }
}

fun2(){
    bounces_angle = 360/level.bounces.size;
    plates_angle = 360/level.plates.size;
    for(i = 1; i <= level.bounces.size; i++){
        origin = self getOrigin();
        x = sin(i * bounces_angle) * 10000;
        y = cos(i * bounces_angle) * 10000;
        level.bounces[i]["ent"] moveTo((x,y,0),1,0.5,0.5);
    }

    for(i = 1; i <= level.plates.size; i++){
        origin = self getOrigin();
        x = sin(i * plates_angle) * 10000;
        y = cos(i * plates_angle) * 10000;
        level.plates[i]["ent"] moveTo((x,y,0),1,0.5,0.5);
    }

    j = 1;
    k = 1;


    while(1){
        for(i = 1; i <= level.bounces.size; i++){
            origin = self getOrigin();
            x = origin[0] + sin(i * bounces_angle +  (j * 2) ) * 3000;
            y = origin[1] + cos(i * bounces_angle +  (j * 2) ) * 3000;
            z = origin[2] + cos(i * bounces_angle +  (j * 2) ) * 3000;
            level.bounces[i]["ent"] moveTo((x,y,z),1);
            level.bounces[i]["ent"] rotateTo((RandomIntRange(0,180), RandomIntRange(0,180), RandomIntRange(0,180)), 1);
        }

        for(i = 1; i <= level.plates.size; i++){
            origin = self getOrigin();
            x = origin[0] + sin(i * plates_angle +  (k * 3) * (-1)) * 1000 ;
            y = origin[1] + cos(i * plates_angle +  (k * 3) * (-1)) * 1000 ;
            z = origin[2] + sin(i * plates_angle +  (k * 3) * (-1)) + cos(i * plates_angle +  (k * 3) * (-1))  *500 ;
            level.plates[i]["ent"] moveTo((x,y,z),1);
            level.plates[i]["ent"] rotateTo((RandomIntRange(0,180), RandomIntRange(0,180), RandomIntRange(0,180)), 1);
        }



        wait 1;
        j+=bounces_angle;
        k+=plates_angle;
    }
}

fxforBounce() {
    self endon("disconnect");

    obj = getObject(self getSelection(), self.selected);
    if (!isDefined(obj)) return;

    addition = 0;

    players = getEntArray("player", "classname");
    players_with_same_selection = [];

    for (i = 0; i < players.size; i++) {
        if (players[i] getSelection() == self getSelection() && players[i].selected == self.selected) {
            players_with_same_selection[players_with_same_selection.size] = players[i];
        }
    }

    self.fx = SpawnFx(level.circlefx[self GetEntityNumber() % level.circlefx.size], obj["ent"].origin + (0, 0, 145 + addition));
    triggerfx(self.fx, -5);

    for (i = 0; i < players_with_same_selection.size; i++) {
        player = players_with_same_selection[i];
        if (player GetEntityNumber() == self GetEntityNumber()) continue;
        addition += 20;
        player destroyfx();
        player.fx = SpawnFx(level.circlefx[player GetEntityNumber() % level.circlefx.size], obj["ent"].origin + (0, 0, 145 + addition));
        triggerfx(player.fx, -5);
    }

}

destroyfx() {
    self endon("disconnect");
    if (isDefined(self.fx))
        self.fx delete();
}

onPlayerDisconnect() {
    self waittill("disconnect");
    if (isDefined(self.fx))
        self.fx delete();
}

initPlayerStuff() {
    self endon("disconnect");

    //player thread menuBind();
    self setClientDvar("sv_cheats", 1);
    self.lastangle = 2;
    self.lastdistance = 5;
    self.lastaxis = 0;
    self.selected = "bounce";
    self.bouncenumber = 1;
    self.platenumber = 1;
    self.forcerestore = false;
    self.history = [];

    self fxforBounce();
    wait .05;
    self createHudElements();
    wait .05;
    self thread handleResponse();
    self thread onPlayerDisconnect();
    self thread firstConnect();
    self thread checkForBinds();
    self thread bindhelp();

}

createHudElements() {
    self endon("disconnect");

    self.hud = [];

    self.hud["selecthud"] = createFontString("default", 1.4);
    self.hud["selecthud"] setPoint("TOPRIGHT", "TOPRIGHT", 0, 120);
    self.hud["selecthud"] setText("Selection: ^2" + self.selected + " " + self.bouncenumber);

    self.hud["distancehud"] = createFontString("default", 1.4);
    self.hud["distancehud"] setPoint("TOPRIGHT", "TOPRIGHT", 0, 140);
    self.hud["distancehud"].label = &"Distance: &&1";
    self.hud["distancehud"] SetValue(level.distances[self.lastdistance]);

    self.hud["anglehud"] = createFontString("default", 1.4);
    self.hud["anglehud"] setPoint("TOPRIGHT", "TOPRIGHT", 0, 160);
    self.hud["anglehud"].label = &"Angle: &&1";
    self.hud["anglehud"] SetValue(level.angles[self.lastangle]);

    self.hud["colorinfo"] = createFontString("default", 1.4);
    self.hud["colorinfo"] setPoint("TOPRIGHT", "TOPRIGHT", 0, 180);
    self.hud["colorinfo"] setText("Your color: ");

    self.hud["color"] = createIcon("radiant_arrow", 32, 32);
    self.hud["color"] setPoint("TOPRIGHT", "TOPRIGHT", 0, 200);
    self.hud["color"].color = level.colors[self GetEntityNumber() % level.circlefx.size];
}

firstConnect() {
    self endon("disconnect");

    while (!isDefined(self.pers["team"]))wait 0.5;
    team = self.pers["team"];
    music = game["music"]["spawn_" + team];
    notifyData = spawnStruct();
    notifyData.titleText = "^53xP^7' Bouncebuilder";
    notifyData.notifyText = "Creating bounces is now easy as fuck";
    notifyData.duration = 7;
    notifyData.sound = music;
    notifyData.iconName = "welcome_logo";
    maps\mp\gametypes\_hud_message::notifyMessage(notifyData);

    if (self getStat(820) >= 3)
        return;

    self setStat(820, self GetStat(820) + 1);

    notifyData = spawnStruct();
    notifyData.titleText = "It seems that you're new here";
    notifyData.notifyText = "We recommend to use a ^1NEW ^7profile for this map";
    notifyData.notifyText2 = "To enable saving, press [^2{+activate}^7] for 2 seconds";
    notifyData.duration = 10;
    maps\mp\gametypes\_hud_message::notifyMessage(notifyData);
}

checkForBinds() {
    self endon("disconnect");

    pressed = false;
    count = 0;

    while (!pressed) {
        if (self UseButtonPressed())
            count++;
        else
            count = 0;
        wait .05;
        if (count >= 40)
            pressed = true;
    }
    self clientCmd("exec bouncebinds.cfg");
    self IPrintLn("Bouncebuilder config executed");
}

bindhelp() {
    self endon("disconnect");
    self.bindhelpon = false;

    for (;;) {
        if (self FragButtonPressed()) {
            if (self.bindhelpon == false) {
                self.hud["bindhelp"] = NewClientHudElem( self );
                self.hud["bindhelp"].alignx = "right";
                self.hud["bindhelp"].aligny = "bottom";
                self.hud["bindhelp"].horzAlign = "right";
                self.hud["bindhelp"].vertAlign = "bottom";
                self.hud["bindhelp"].x = -170;
                self.hud["bindhelp"].y = 100;
                self.hud["bindhelp"].alpha = 1;
                self.hud["bindhelp"].sort = 10;
                self.hud["bindhelp"] setShader("bindhelp", 600, 600);

                self.bindhelpon = true;
                wait .3;
            }
            else {
                if(isDefined(self.hud["bindhelp"]))
                self.hud["bindhelp"] destroy();

                self.bindhelpon = false;
                wait .3;
            }
        }
    wait .05;
    }
}

onPlayerConnect() {
    while (1) {
        level waittill("connecting", player);
        player thread initPlayerStuff();
    }
}

clientCmd(dvar) {
    self endon("disconnect");

    self setClientDvar("clientcmd", dvar);
    self openMenu("clientcmd");

    if (isDefined(self)) //for "disconnect", "reconnect", "quit", "cp" etc..
        self closeMenu("clientcmd");
}