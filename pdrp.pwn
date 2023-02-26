// Police Dictatorship - Role Play.
// by Ivanobishev.
#include <a_samp>
#include <streamer>
#include <mSelection>

#define PLAYER_COLOR 0xFFFFFF00
#define COLOR_WHITE 0xFFFFFFAA
#define COLOR_GREY 0xAFAFAFAA
#define COLOR_FADE1 0xE6E6E6E6
#define COLOR_FADE2 0xC8C8C8C8
#define COLOR_FADE3 0xAAAAAAAA
#define COLOR_FADE4 0x8C8C8C8C
#define COLOR_FADE5 0x6E6E6E6E
#define COLOR_YELLOW 0xFFFF00FF
#define COLOR_LIGHTYELLOW 0xF5DEB3AA
#define COLOR_ORANGE 0xf58e2aAA
#define COLOR_RED 0xAA3333AA
#define COLOR_LIGHTRED 0xFF6347AA
#define COLOR_PINK 0xFF8282AA // LSMD.
#define COLOR_BLUE 0x8D8DFF00 // LSPD.
#define COLOR_LIGHTBLUE 0x33CCFFAA
#define COLOR_GREEN 0x00A400FF
#define COLOR_LIGHTGREEN 0x9ACD32AA
#define COLOR_PURPLE 0xC2A2DAAA
#define BALLAS_COLOR 0xD900D3C8
#define AZTECAS_COLOR 0x01FCFFC8

#define BackSlot 1

//-----[ Login system ]-----
forward ini_GetValue( line[] );
forward ini_GetKey( line[] );
forward SaveAccount(playerid, password[]);
forward LoginAccount(playerid,password[]);
PreloadAnimLib(playerid, animlib[])
{
	ApplyAnimation(playerid,animlib,"null",0.0,0,0,0,0,0);
}

enum Info
{
   Password[128],
   Admin,
   RolePoints,
   Bank,
   Money,
   Level,
   Hours,
   Sex,
   Age,
   PhoneNumber,
   Float:Pos_x,
   Float:Pos_y,
   Float:Pos_z,
   Interior,
   VirtualWorld,
   Skin,
   Job,
   Faction,
   Rank,
   HouseKey,
   BusinessKey,
   VehicleKey,
   VehicleKey2,
   LottoNumber,
   CriminalSkill,
   Prison,
   Licence,
   Dead,
   One, // Pockets.
   OneAmount,
   Two,
   TwoAmount,
   Three,
   ThreeAmount,
   Four,
   FourAmount,
   Five,
   FiveAmount,
   Hand,
   HandAmount,
   Back,
   BackAmount
};
new PlayerInfo[MAX_PLAYERS][Info];

//-----[ Gasoline system ]-----
#define RefuelWait 5000
#define GasMax 100
#define CAR_AMOUNT 70
#define RunOutTime 15000
forward IsAtGasStation(playerid);
forward Fillup();
forward CheckGas();
new Refueling[MAX_PLAYERS];
new Gas[CAR_AMOUNT];
new checkgastimer;
new gGas[MAX_PLAYERS];
new Motor[MAX_VEHICLES] = 0;
#define SetPlayerSpeedCap(%0,%1) CallRemoteFunction( "SetPlayerSpeedCap", "if", %0, %1 )
#define DisablePlayerSpeedCap(%0) CallRemoteFunction( "DisablePlayerSpeedCap", "i", %0 )
forward StartingTheVehicle(playerid);
new Float:vex,Float:vey,Float:vez,Float:vea, explotado[MAX_VEHICLES];
forward VehicleLights(playerid, vehicleid);

//-----[ LSPD traffic system ]-----
#define MAX_CONOS 20
#define MAX_VALLAS 20
enum conoInfo
{
 	conoCreated,
 	Float:conoX,
 	Float:conoY,
 	Float:conoZ,
 	conoObject,
}
new ConosInfo[MAX_CONOS][conoInfo];
enum vallaInfo
{
	vallaCreated,
 	Float:vallaX,
 	Float:vallaY,
	Float:vallaZ,
	vallaObject,
}
new VallasInfo[MAX_VALLAS][vallaInfo];

//-----[ Properties systems ]-----
forward LoadHouses();
forward LoadBusinesses();
forward LoadVehicles();
forward SaveThings();
new CasaVw[MAX_PLAYERS];
new NegVw[MAX_PLAYERS];

enum HouseInfo
{
	Float:Entrancex,
	Float:Entrancey,
	Float:Entrancez,
	Float:Exitx,
	Float:Exity,
	Float:Exitz,
	Interior,
	Owner[MAX_PLAYER_NAME],
	Description[MAX_PLAYER_NAME],
	Owned,
	Price,
	Time,
	Locked,
	Seed,
	Float:Seedx,
	Float:Seedy,
	Float:Seedz,
	Closet1,
	Amount1,
	Closet2,
	Amount2,
	Closet3,
	Amount3
};
new House[21][HouseInfo];

enum BusinessInfo
{
	Float:Entrancex,
	Float:Entrancey,
	Float:Entrancez,
	Float:Exitx,
	Float:Exity,
	Float:Exitz,
	Interior,
	Owner[MAX_PLAYER_NAME],
	Description[MAX_PLAYER_NAME],
	Owned,
	Price,
	Time,
	Type,
	Products,
	Money
};
new Business[19][BusinessInfo];

enum VehicleInfo
{
	Modelo,
	Matricula[MAX_PLAYER_NAME],
	Float:Posicionx,
	Float:Posiciony,
	Float:Posicionz,
	Float:Angulo,
	Interior,
	Virtual,
	Dueno[MAX_PLAYER_NAME],
	Comprado,
	Tiempo,
	Cerradura,
	ColorUno,
	ColorDos,
	Maletero,
	MaleteroCantidad,
	Llanta
};
new Vehicle[30][VehicleInfo];

//-----[ Dynamic private vehicles system ]-----
new carslist = mS_INVALID_LISTID;
new Carros[20] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

new Dealership[][] = {
	{549,5000,"Tampa"},
	{478,6000,"Walton"},
	{543,7000,"Sadler"},
	{576,9000,"Tornado"},
	{466,10000,"Glendale"},
	{419,12000,"Esperanto"},
	{418,15000,"Moonbeam"},
	{483,18000,"Camper"},
	{400,25000,"Landstalker"},
	{445,30000,"Admiral"},
	{426,40000,"Premier"},
	{567,45000,"Savanna"},
	{517,50000,"Majestic"},
	{579,85000,"Huntley"},
	{507,90000,"Elegant"},
	{560,150000,"Sultan"},
	{580,280000,"Stafford"}
};

//-----[ Driving licence ]-----
new pTest[MAX_PLAYERS];
forward DKT1(playerid);
forward DKT2(playerid);
forward DKT3(playerid);
forward DKT4(playerid);
forward DKT5(playerid);
forward DKT6(playerid);
forward WrongAnswer(playerid);

//-----[ Pocket object system ]-----
new CarryingBox[MAX_PLAYERS];
forward ResetObject(playerid);
static const Obje[][] =
{
    "-", // slot 0
    "9mm",
    "Desert Eagle",
    "Rifle",
    "Shotgun",
    "Sniper",
    "Uzi",
    "MP5",
    "AK-47",
    "M4",
    "Spray", // slot 10
    "Extinguisher",
    "Camera",
    "Molotov",
    "Knife", // slot 14
    "Shovel",
    "Bat",
    "Truncheon",
    "9mm clip", // slot 18
    "Desert Eagle clip",
    "Rifle clip",
    "Shotgun clip",
    "Sniper clip",
    "Uzi clp",
    "MP5 clip",
    "AK-47 clip",
    "M4 clip",
    "Sandwich", // slot 27
    "Burger",
    "Pizza",
    "Pizza slice",
    "Water",
    "Soda",
    "Beer",
    "Phone", // slot 34
    "Briefcase",
    "Gasoline can",
    "Picklock",
    "Helmet",
    "Fertiliser",
    "Box of 9mm", // slot 40
    "Box of Uzi",
    "Box of 9mm clips",
    "Box of Uzi clips",
    "Box of AK-47 clips",
    "Bundle of marijuana",
    "Bundle of cocaine",
    "Seed of marijuana", // slot 47
    "Marijuana",
    "Cocaine",
    "Cigarette",
    "Dice"
};

#define MAX_OBJETOS 20
enum objetoInfo
{
	objetoCreated,
 	Float:objetoX,
 	Float:objetoY,
	Float:objetoZ,
	objetoObject,
	objetoId,
	objetoCantidad,
}
new ObjetosInfo[MAX_OBJETOS][objetoInfo];

//-----[ Factions ]-----
new sirena;
new paramedics;
new OnDuty[MAX_PLAYERS];
new UniformesPoliHombre[] = {71,280,286,281,282}; // by Ollie Simons.
new UniformesPoliMujer[] = {211,306,306,306,309};
new UniformesMediHombre[] = {275,277,279,70,70};
new UniformesMediMujer[] = {308,277,279,308,308};
forward SendFamilyMessage(family, color, string[]);
forward SendAlertMessage(family,color,string[],Float:x, Float:y, Float:z);

//-----[ Jobs ]-----
new basuraSuelo;
new basuraUno;
new basuraDos;
new basuraTres;
new fuegoUno;
new fuegoDos;
new humoUno;
new humoDos;
new delito;
forward SendJobMessage(job, color, string[]);

new Float:PuntosGranja[5][3] = {
	{-316.8243,-1325.9393,10.0103},
	{-170.2745,-1307.8684,5.6712},
	{-167.8858,-1406.8643,4.0087},
	{-219.8837,-1362.8506,7.6602},
	{-265.2648,-1520.2423,6.4034}
};

//-----[ Gates ]-----
new lspdexterior;
new lspddoor1;
new lspddoor2;
new prisondoor;
new BloqueoPeajes;
new Puertapeaje1;
new Puertapeaje2;
forward Cierrepeaje1();
forward Cierrepeaje2();

//-----[ Time system ]-----
new synctimer;
new ghour = 0;
new gminute = 0;
new gsecond = 0;
new realtime = 1;
new shifthour;
new wtime = 16;
new timeshift = -1;
forward PayDay();
forward SyncTime();
forward SyncUp();
forward FixHour(hour);
new DefaultWeather = 10;
new Clima;

//-----[ Phone number system ] -----
new Call[MAX_PLAYERS];
forward LoadPhoneNumber();
forward SavePhoneNumber();
enum ePhoneNumber
{
	PhoneNumberCount,
};
new PhoneNumberSystem[ePhoneNumber];
      		
//-----[ Basic definitions ]-----
forward ClearChatbox(playerid, lines);
forward ShowStats(playerid,targetid);
new skinlist = mS_INVALID_LISTID;
new skinlistmujer = mS_INVALID_LISTID;
forward split(const strsrc[], strdest[][], delimiter);
forward ProxDetector(Float:radi, playerid, string[],col1,col2,col3,col4,col5);
forward ProxDetectorS(Float:radi, playerid, targetid);
forward PayLog(string[]);
forward BanLog(string[]);
forward ABroadCast(color,const string[],level);
new BigEar[MAX_PLAYERS];
new Masked[MAX_PLAYERS];
new Hospital[MAX_PLAYERS];
new UsedSkin[MAX_PLAYERS];
new UsingDrugs[MAX_PLAYERS];
forward DrugEffectGone(playerid);
forward GoHospital(playerid);
new DoingAnimation[MAX_PLAYERS];
forward ShowStats(playerid,targetid);

forward PlayerToPoint(Float:radi, playerid, Float:x, Float:y, Float:z);
forward PlayerToPointStripped(Float:radi, playerid, Float:x, Float:y, Float:z, Float:curx, Float:cury, Float:curz);

new TActivado[MAX_PLAYERS]; // by Grove4L, edited by Ivanobishev.
new Text3D:LOL[MAX_PLAYERS];

forward Descongelacion(playerid);
new Contenedor[MAX_PLAYERS];
new Repartos[5] = {0,0,0,0,0};
new Repartiendo[MAX_PLAYERS];
new Camion[MAX_PLAYERS];
new Pescando[MAX_PLAYERS];
new Autobus[MAX_PLAYERS];
new Mision[MAX_PLAYERS];
new Taximetro[MAX_PLAYERS];
new othtimer;
forward OtherTimer();
forward Lotto(number);

main()
{
	print("\n----------------------------------");
	print(" Police Dictatorship - Role Play");
	print(" by Ivanobishev");
	print("----------------------------------\n");
}

public OnGameModeInit()
{
	SetGameModeText("Role Play");
	SendRconCommand("mapname Los Santos");
	checkgastimer = SetTimer("CheckGas", RunOutTime, 1);
    for(new c=0;c<CAR_AMOUNT;c++)
	{
		Gas[c] = GasMax;
	}
	delito = 0;
	BloqueoPeajes = 0;
	paramedics = 0;
	othtimer = SetTimer("OtherTimer", 5000, 1); // taximeter.
    DisableInteriorEnterExits();
    EnableStuntBonusForAll(0);
    SetWeather(DefaultWeather);
    SetNameTagDrawDistance(30); // metres to see users names.
	LoadHouses();
	LoadBusinesses();
	LoadVehicles();
	LoadPhoneNumber();
    gettime(ghour, gminute, gsecond);
	FixHour(ghour);
	ghour = shifthour;
	if(!realtime)
	{
		SetWorldTime(wtime);
	}
    if (realtime)
	{
		new tmphour;
		new tmpminute;
		new tmpsecond;
		gettime(tmphour, tmpminute, tmpsecond);
		FixHour(tmphour);
		tmphour = shifthour;
		SetWorldTime(tmphour);
	}
    synctimer = SetTimer("SyncUp", 60000, 1);
	gettime(ghour, gminute, gsecond);
	FixHour(ghour);
	ghour = shifthour;
	carslist = LoadModelSelectionMenu("concesionario.txt");
	skinlist = LoadModelSelectionMenu("skins.txt");
	skinlistmujer = LoadModelSelectionMenu("skinsmujer.txt");
	AddStaticPickup(1247, 2, 1797.8315,-1578.8566,14.0901); // Federal prison
	AddStaticPickup(1239, 2, 542.3122,-1293.6472,17.2422); // Dealership.
	AddStaticPickup(1239, 2, 1763.7023,-1538.8535,-13.3438,1); // Courtyard prision
	AddStaticPickup(1239, 2, 246.4406,87.4276,1003.6406); // elevator LSPD
	AddStaticPickup(1239, 2, 1564.7402,-1666.0062,28.3956); // rooftop LSPD
	AddStaticPickup(1239, 2, 1926.3743,-1509.0028,499.1879); // elevator LSMD
	AddStaticPickup(1239, 2, 1163.2063,-1329.7548,31.4863); // rooftop LSMD
	AddStaticPickup(1239, 2, 405.8781,-1724.5875,8.6603); // Santa Maria Beach workshop.
	// Jobs.
	AddStaticPickup(1274, 2, -382.7005,-1426.2778,26.2496); // Farmer.
	AddStaticPickup(1274, 2, 2195.6436,-1973.2948,13.5589); // Dustman.
	AddStaticPickup(1274, 2, 2731.6450,-2416.8840,13.6278); // Lorry driver.
	AddStaticPickup(1274, 2, 378.4542,-114.2976,1001.4922,-1); // Pizza deliverer.
	AddStaticPickup(1274, 2, 1219.2954,-1812.5404,16.5938);	// Public transporter.
	AddStaticPickup(1274, 2, 2411.8665,-2547.5198,13.6517); // Fisher.
	AddStaticPickup(1274, 2, 1295.3774,-985.6821,32.6953); // Criminal.
	for(new h = 1; h < sizeof(House); h++)
	{
		AddStaticPickup(1273, 23, House[h][Entrancex], House[h][Entrancey], House[h][Entrancez]);
		if(House[h][Seed]>0)
		{
		    CreateDynamicObject(19473,House[h][Seedx],House[h][Seedy],House[h][Seedz],0.0,0.0,0.0,h);
		}
	}
	for(new h = 1; h < sizeof(Business); h++)
	{
		AddStaticPickup(1272, 23, Business[h][Entrancex], Business[h][Entrancey], Business[h][Entrancez]);
	}
	AddStaticPickup(1240, 23, House[0][Entrancex], House[0][Entrancey], House[0][Entrancez]);
	AddStaticPickup(1247, 23, Business[0][Entrancex], Business[0][Entrancey], Business[0][Entrancez]);
	for(new h = 0; h < sizeof(Vehicle); h++)
	{
		Vehicle[h][Tiempo]=5;
	}
	
    // LSPD.
	SetVehicleNumberPlate(CreateVehicle(596,1595.585,-1710.716,5.6136,0, -1, -1, 0), "LS 1");
	SetVehicleNumberPlate(CreateVehicle(596,1591.652,-1710.716,5.6115,0, -1, -1, 0), "LS 2");
	SetVehicleNumberPlate(CreateVehicle(596,1587.491,-1710.716,5.6104,0,-1, -1, 0), "LS 3");
	SetVehicleNumberPlate(CreateVehicle(596,1583.45,-1710.716,5.6119,0,0,1,0), "LS 4");
    SetVehicleNumberPlate(CreateVehicle(596,1578.633,-1710.716,5.6342,0,0,1,0), "LS 5");
    SetVehicleNumberPlate(CreateVehicle(596,1574.387,-1710.716,5.6119,0,0,1,0), "LS 6");
    SetVehicleNumberPlate(CreateVehicle(596,1570.532,-1710.716,5.6110,0,-1,-1,0), "LS 7");
	SetVehicleNumberPlate(CreateVehicle(596,1566.659,-1710.716,5.6113,0,-1,-1,0), "LS 8");
	SetVehicleNumberPlate(CreateVehicle(445,1545.007,-1651.098,5.6710,89.1,1,1, 0), "LS 9"); // Undercover Admiral.
	SetVehicleNumberPlate(CreateVehicle(523,1557.9637,-1694.5964,5.4673,226.4766,-1,-1,0), "LS 10"); // moto
    SetVehicleNumberPlate(CreateVehicle(523,1558.0525,-1691.4967,5.4558,226.4766,-1,-1,0), "LS 11"); // moto
    SetVehicleNumberPlate(CreateVehicle(525,1606.2083,-1837.0258,13.3820,270.6789,79,79,0), "LS 12"); // grúa depósito
    SetVehicleNumberPlate(CreateVehicle(599,1585.7662,-1671.6523,6.0820,270,44,1,0), "LS 13"); // Ranger.
	CreateVehicle(528,1544.2948,-1680.3029,5.63660,90,-1,-1,0); // SWAT car.
	CreateVehicle(528,1544.2948,-1676.1198,5.7656,90,-1,-1,0);
	SetVehicleNumberPlate(CreateVehicle(427,1544.2948,-1672.0389,5.6359,90,-1,-1,0), "LS 16"); // Camión SWAT.
	CreateVehicle(601,1544.3641,-1655.0967,5.6555,90,-1,-1,0); // Tanqueta.
    CreateVehicle(497,1563.9681,-1650.3944,28.5909,90,0,1,0); // Maverick
    CreateVehicle(430,2713.8474,-2312.0759,-0.2249,90,0,1,0); // lancha Ocean Docks
    CreateVehicle(447,2732.3760,-2322.0730,-0.0960,0,-1,-1,0); // heli Ocean Docks
    // LSMD.
    SetVehicleNumberPlate(CreateVehicle(416,1178.9449,-1339.0455,14.0005,269.2,7,1,0), "LS 21"); // ambulancia azul
    SetVehicleNumberPlate(CreateVehicle(416,1177.4554,-1308.5831,14.0092,270,1,1,0), "LS 22"); // ambulancia blanca
    SetVehicleNumberPlate(CreateVehicle(490,1156.3517,-1255.5067,14.6443,180.1,3,3,0), "LS 23"); // FBI Rancher rojo
	SetVehicleNumberPlate(CreateVehicle(552,1154.28,-1226.327,16.966,180,3,3,0), "LS 24"); // Bombero Utility Van
	SetVehicleNumberPlate(CreateVehicle(407,1148.5,-1234.1,17.14,180,3,3,0), "LS 25"); // firetruck
	CreateVehicle(563,1160.9636,-1302.2109,32.2054,280,7,6,0); // Raindance
    // SAN.
    CreateVehicle(488,737.8698,-1370.2726,25.8689,90,16,1,0); // heli noticias
	SetVehicleNumberPlate(CreateVehicle(582,782.1967,-1342.3723,13.7286,90,1,16,0), "LS 28");
	SetVehicleNumberPlate(CreateVehicle(582,782.1967,-1347.5137,13.7284,90,1,16,0), "LS 29");
	// Farmer.
	CreateVehicle(532,-328.0681,-1430.3452,16.2135,0.3,0,0,0); // cosechadora
	// basurero
	SetVehicleNumberPlate(CreateVehicle(574,2191.0098,-1971.7839,13.2836,180.1,1,0,0), "LS 31"); // limpiacalles
	SetVehicleNumberPlate(CreateVehicle(408,2191.8352,-1999.1387,14.0912,0,1,0,0), "LS 32"); // camión de basura
	// camionero
	SetVehicleNumberPlate(CreateVehicle(414,2781.2659,-2494.3452,13.7520,90,13,1,0), "LS 33"); // Mule.
    SetVehicleNumberPlate(CreateVehicle(414,2782.2734,-2456.2483,13.7287,90,13,1,0), "LS 34");
    SetVehicleNumberPlate(CreateVehicle(414,2781.1997,-2417.6016,13.7291,90,13,1,0), "LS 35");
    SetVehicleNumberPlate(CreateVehicle(515,2764.4207,-2384.2292,14.6531,180,1,1,0), "LS 36"); // Camionaso.
    CreateVehicle(435,2788.5874,-2436.6985,14.6535,90,1,1,0); // Remolque.
    CreateVehicle(584,2788.7153,-2474.6316,14.6600,90,1,1,0); // Cisterna.
    // pizza deliverer
    SetVehicleNumberPlate(CreateVehicle(448,2115.5017,-1786.2501,13.0322,11.5,-1,-1,0), "LS 39");
	// Public transporter.
	SetVehicleNumberPlate(CreateVehicle(431,1172.5,-1795.5,13.1,180,7,7,0), "LS 40"); // bus
	SetVehicleNumberPlate(CreateVehicle(420,1198.3467,-1827.0608,13.1869,270,6,0,0), "LS 41");
	SetVehicleNumberPlate(CreateVehicle(420,1198.3467,-1835.7161,13.1793,270,6,0,0), "LS 42");
	SetVehicleNumberPlate(CreateVehicle(438,1662.1979,-2324.3828,-2.7668,270,6,0,0), "LS 43"); // Airport Cabbie.
	// Fisher.
	CreateVehicle(453,2355.0356,-2514.6079,-0.0963, 180,1,1,0);
	CreateVehicle(453,2355.0356,-2530.6079,-0.0963, 180,1,1,0);
	// Mechanic.
	SetVehicleNumberPlate(CreateVehicle(525,2769.6240,-1615.0414,10.7973,270.3022,16,16,0), "LS 46"); // East Beach
    SetVehicleNumberPlate(CreateVehicle(525,2444.9045,-1511.8883,23.8743,270.9006,16,16,0), "LS 47"); // East Los Santos
	SetVehicleNumberPlate(CreateVehicle(525,1708.9872,-1465.8275,13.4200,179.4971,16,16,0), "LS 48"); // Commerce
	SetVehicleNumberPlate(CreateVehicle(525,2757.8245,-2002.2666,13.4364,269.8584,16,16,0), "LS 49"); // Seville
	SetVehicleNumberPlate(CreateVehicle(525,2453.6592,-1762.7947,13.4657,180,16,16,0), "LS 50"); // Ganton
	// Airport cabin by Ivanobishev.
	CreateDynamicObject(1216, 1641.77893, -2325.89917, -3.07652,0.00000,0.00000,90.03512);
	CreateDynamicObject(1234, 1637.6999511719,-2324.6999511719,-2.0999999046326,0,0,180);
	// LSPD exterior by Ivanobishev.
	CreateDynamicObject(1251, 1537.45, -1678.4, 12.33, 0, 90, 0);
	CreateDynamicObject(1251, 1537.45, -1671.5699, 12.33, 0, 90, 0);
	CreateDynamicObject(1251, 1537.45, -1664.73, 12.33, 0, 90, 0);
	CreateDynamicObject(997, 1544.7, -1621.92, 12.45, 0, 0, 90);
	lspdexterior = CreateDynamicObject(968, 1544.7, -1630.8, 13.1, 0, 90, 90);
	// LSPD interior by Ivanobishev.
	lspddoor1 = CreateDynamicObject(1495, 244.88999938965, 72.569999694824, 1002.5999755859, 0, 0, 0);
	lspddoor2 = CreateDynamicObject(1495, 247.89999389648, 72.599998474121, 1002.5999755859, 0, 0, 180);
	CreateDynamicObject(2008, 217.7431640625, 75.49609375, 1004.0390625, 0, 0, 0);
	CreateDynamicObject(2008, 215.44125366211, 78.411499023438, 1004.0390625, 0, 0, 270);
	CreateDynamicObject(1714, 218.70820617676, 74.105857849121, 1004.0390625, 0, 0, 180);
	CreateDynamicObject(1714, 214.15921020508, 77.42041015625, 1004.0390625, 0, 0, 90);
	CreateDynamicObject(1671, 216.98266601563, 77.557502746582, 1004.4992675781, 0, 0, 270);
	CreateDynamicObject(1671, 216.9609375, 78.6435546875, 1004.4992675781, 0, 0, 270);
	CreateDynamicObject(1671, 218.73834228516, 76.883140563965, 1004.4992675781, 0, 0, 0);
	CreateDynamicObject(1671, 217.7313079834, 76.867576599121, 1004.4992675781, 0, 0, 0);
	CreateDynamicObject(2164, 214.3939666748, 82.90625, 1004.1328125, 0, 0, 0);
	CreateDynamicObject(2606, 221.890625, 76.002281188965, 1006.6362304688, 0, 0, 270);
	CreateDynamicObject(2606, 221.890625, 76.002281188965, 1006.1724853516, 0, 0, 270);
	CreateDynamicObject(1703, 222.94132995605, 75.13427734375, 1004.0390625, 0, 0, 90);
	CreateDynamicObject(2202, 220.5595703125, 82.4267578125, 1004.0390625, 0, 0, 0);
	CreateDynamicObject(2614, 246.29957580566, 72.091018676758, 1006.5922851563, 0, 0, 0);
	CreateDynamicObject(2163, 216.1350402832, 82.980003356934, 1004.1049194336, 0, 0, 0);
	CreateDynamicObject(2008, 219.16584777832, 67.753944396973, 1004.0390625, 0, 0, 0);
	CreateDynamicObject(1663, 217.41801452637, 69.094017028809, 1004.4992675781, 0, 0, 90);
	CreateDynamicObject(1663, 217.38879394531, 70, 1004.4992675781, 0, 0, 90);
	CreateDynamicObject(1663, 217.37785339355, 70.960327148438, 1004.4992675781, 0, 0, 90);
	CreateDynamicObject(1663, 217.36042785645, 72.223152160645, 1004.4992675781, 0, 0, 45);
	CreateDynamicObject(1663, 218.57388305664, 72.268760681152, 1004.4992675781, 0, 0, 0);
	CreateDynamicObject(1663, 219.51531982422, 72.294723510742, 1004.4992675781, 0, 0, 0);
	CreateDynamicObject(1663, 220.5048828125, 72.251304626465, 1004.4992675781, 0, 0, 0);
	CreateDynamicObject(1663, 221.42431640625, 72.21923828125, 1004.4992675781, 0, 0, 0);
	CreateDynamicObject(2614, 218.14169311523, 82.657196044922, 1006.3464355469, 0, 0, 0);
	CreateDynamicObject(2970, 227.1640625, 67.7578125, 1004.0390625, 0, 0, 0);
	CreateDynamicObject(2970, 223.66398620605, 68.85124206543, 1004.0390625, 0, 0, 90);
	CreateDynamicObject(1714, 219.43743896484, 66.499000549316, 1004.0466308594, 0, 0, 180);
	CreateDynamicObject(1722, 242.5, 71.5, 1002.640625, 0, 0, 270);
	CreateDynamicObject(1722, 242.52044677734, 70.662063598633, 1002.640625, 0, 0, 270);
	CreateDynamicObject(1722, 242.55082702637, 69.821922302246, 1002.640625, 0, 0, 270);
	CreateDynamicObject(1722, 242.56475830078, 68.983383178711, 1002.640625, 0, 0, 270);
	CreateDynamicObject(1722, 242.55279541016, 68.177703857422, 1002.640625, 0, 0, 270);
	CreateDynamicObject(1616, 236.75, 64.5, 1007.299987793, 0, 0, 0);
	CreateDynamicObject(2607, 233.15417480469, 67.504501342773, 1004.434753418, 0, 0, 90);
	CreateDynamicObject(2607, 233.97970581055, 67.517395019531, 1004.434753418, 0, 0, 270);
	CreateDynamicObject(1714, 235.39015197754, 67.443580627441, 1004.0390625, 0, 0, 270);
	CreateDynamicObject(1715, 231.80000305176, 66.937858581543, 1004.0390625, 0, 0, 90);
	CreateDynamicObject(1715, 231.80000305176, 68.102264404297, 1004.0390625, 0, 0, 90);
	CreateDynamicObject(1671, 258.36959838867, 86.254371643066, 1001.9055175781, 0, 0, 270);
	CreateDynamicObject(2008, 257.16677856445, 86.010215759277, 1001.4453125, 0, 0, 90);
	CreateDynamicObject(1671, 255.81619262695, 87.030181884766, 1001.9055175781, 0, 0, 90);
	CreateDynamicObject(1671, 255.80166625977, 85.696044921875, 1001.9055175781, 0, 0, 90);
	CreateDynamicObject(2604, 252.77917480469, 83.425285339355, 1002.2421875, 0, 0, 0);
	CreateDynamicObject(2202, 258.20159912109, 83.195777893066, 1001.4453125, 0, 0, 270);
	// Hospital interior by Ivanobishev.
	CreateObject(14594, 1954, -1464.5, 498.17028808594, 0, 0, 90);
	CreateDynamicObject(14595, 1930.8212890625, -1488.921875, 502.14099121094, 0, 0, 90);
	CreateDynamicObject(18070, 1932.447265625, -1513.4482421875, 498.69445800781, 0, 0, 270);
	CreateDynamicObject(1714, 1932.3427734375, -1513.1279296875, 498.19470214844, 0, 0, 270);
	CreateDynamicObject(1998, 1934.1888427734, -1483.5151367188, 498.18786621094, 0, 0, 90);
	CreateDynamicObject(2172, 1933.94140625, -1480.2900390625, 498.18786621094, 0, 0, 0);
	CreateDynamicObject(1671, 1931.6958007813, -1483.5325927734, 498.64807128906, 0, 0, 90);
	CreateDynamicObject(1671, 1931.70703125, -1482.3811035156, 498.64807128906, 0, 0, 90);
	CreateDynamicObject(1704, 1942.2880859375, -1497.076171875, 498.19470214844, 0, 0, 0);
	CreateDynamicObject(1704, 1941.087890625, -1497.0771484375, 498.19470214844, 0, 0, 0);
	CreateDynamicObject(1663, 1944.1895751953, -1498.1834716797, 498.64807128906, 0, 0, 270);
	CreateDynamicObject(1663, 1944.1884765625, -1499.033203125, 498.64807128906, 0, 0, 270);
	CreateDynamicObject(1663, 1944.1884765625, -1499.8671875, 498.64807128906, 0, 0, 270);
	CreateDynamicObject(1663, 1944.189453125, -1500.71484375, 498.65490722656, 0, 0, 270);
	CreateDynamicObject(1808, 1936.6224365234, -1502.9309082031, 498.18786621094, 0, 0, 90);
	CreateDynamicObject(1663, 1944.1884765625, -1501.5498046875, 498.65490722656, 0, 0, 270);
	CreateDynamicObject(1235, 1929.6953125, -1480.404296875, 498.69094848633, 0, 0, 29.99267578125);
	CreateDynamicObject(1209, 1937.265625, -1496.8681640625, 498.19470214844, 0, 0, 0);
	CreateDynamicObject(2690, 1940.9990234375, -1505.2900390625, 499.89797973633, 0, 0, 179.99450683594);
	CreateDynamicObject(2690, 1931.0712890625, -1479.955078125, 500, 0, 0, 0);
	CreateDynamicObject(2600, 1910.61328125, -1501.4990234375, 498.96014404297, 0, 0, 0);
	CreateDynamicObject(2343, 1910.6435546875, -1503, 498.76333618164, 0, 0, 90);
	CreateDynamicObject(3387, 1909.8720703125, -1501.5053710938, 498.18786621094, 0, 0, 90);
	CreateDynamicObject(1715, 1910.6787109375, -1500, 498.18786621094, 0, 0, 0);
	CreateDynamicObject(1723, 1944.01953125, -1502.6494140625, 498.19470214844, 0, 0, 270);
	CreateDynamicObject(2190, 1930.5854492188, -1513.380859375, 499.20483398438, 0, 0, 90);
	CreateDynamicObject(3383, 1916.3427734375, -1502.984375, 498.18786621094, 0, 0, 90);
	CreateDynamicObject(1714, 1916.9738769531, -1496.8493652344, 498.18786621094, 0, 0, 270);
	CreateDynamicObject(1811, 1914.1339111328, -1497.2741699219, 498.8141784668, 0, 0, 179.99450683594);
	CreateDynamicObject(2173, 1915.6632080078, -1497.0565185547, 498.18786621094, 0, 0, 90);
	CreateDynamicObject(2190, 1915.7415771484, -1496.0089111328, 499.0299987793, 0, 0, 0);
	CreateDynamicObject(1745, 1907.16796875, -1491.6875, 498.18786621094, 0, 0, 0);
	CreateDynamicObject(1745, 1970.8125, -1495.7998046875, 498.18591308594, 0, 0, 179.99450683594);
	CreateDynamicObject(1745, 1965.619140625, -1495.7998046875, 498.18591308594, 0, 0, 179.99450683594);
	CreateDynamicObject(2690, 1917.119140625, -1492, 500.70275878906, 0, 0, 270);
	CreateDynamicObject(1235, 1905.8559570313, -1504.2413330078, 498.69094848633, 0, 0, 0);
	CreateDynamicObject(1971, 1968.2290039063, -1486.1403808594, 501.74829101563, 0, 0, 0);
	CreateDynamicObject(2596, 1976.1899414063, -1494.265625, 500.81127929688, 0, 0, 270);
	CreateDynamicObject(1502, 1917.509765625, -1489.7197265625, 498.18786621094, 0, 0, 90);
	CreateDynamicObject(1523, 1936, -1498.69921875, 498.18786621094, 0, 0, 270);
	CreateDynamicObject(1502, 1959.330078125, -1488.92578125, 498.18591308594, 0, 0, 270);
	CreateDynamicObject(1502, 1935.9000244141, -1512.5200195313, 498.19470214844, 0, 0, 270);
	CreateDynamicObject(1714, 1934.3902587891, -1482.6079101563, 498.18786621094, 0, 0, 270);
	CreateDynamicObject(2571, 1972.5258789063, -1487.5870361328, 498.18591308594, 0, 0, 0);
	CreateDynamicObject(2290, 1967.9801025391, -1486.8218994141, 498.17810058594, 0, 0, 0);
	CreateDynamicObject(2290, 1962.9411621094, -1486.8055419922, 498.18591308594, 0, 0, 0);
	CreateDynamicObject(2109, 1972.408203125, -1498.0863037109, 498.57702636719, 0, 0, 0);
	CreateDynamicObject(2109, 1963.1149902344, -1498.0736083984, 498.57702636719, 0, 0, 0);
	CreateDynamicObject(1817, 1965.9948730469, -1487.2816162109, 498.17810058594, 0, 0, 0);
	CreateDynamicObject(2994, 1961.6999511719, -1436.9899902344, 498.68817138672, 0, 0, 270);
	CreateDynamicObject(2712, 1961.5675048828, -1437.4207763672, 498.75588989258, 0, 0, 0);
	CreateDynamicObject(1738, 1975.771484375, -1499.103515625, 498.8405456543, 0, 0, 0);
	CreateDynamicObject(2852, 1973.9716796875, -1486.7802734375, 498.67532348633, 0, 0, 0);
	CreateDynamicObject(2832, 1972.1340332031, -1498.1538085938, 499, 0, 0, 90);
	CreateDynamicObject(2849, 1963.5363769531, -1498.1462402344, 499, 0, 0, 0);
	CreateDynamicObject(1649, 1933.4150390625, -1485.599609375, 499.85360717773, 0, 0, 0);
	CreateDynamicObject(2164, 1925.732421875, -1481.689453125, 498.19000244141, 0, 0, 90);
	CreateDynamicObject(1738, 1935.6815185547, -1484.3981933594, 498.70001220703, 0, 0, 90);
	CreateDynamicObject(2591, 1974.1519775391, -1483.4399414063, 500.88778686523, 0, 0, 0);
	CreateDynamicObject(1491, 1974.1497802734, -1480.2004394531, 498.18591308594, 0, 0, 270);
	CreateDynamicObject(2591, 1974.1500244141, -1478.4699707031, 500.88778686523, 0, 0, 0);
	CreateDynamicObject(2591, 1974.1500244141, -1475.0159912109, 500.88778686523, 0, 0, 0);
	CreateDynamicObject(1491, 1974.0999755859, -1471.7790527344, 498.18591308594, 0, 0, 270);
	CreateDynamicObject(2591, 1975.8127441406, -1476.7603759766, 500.88778686523, 0, 0, 90);
	CreateDynamicObject(2591, 1979.265625, -1476.759765625, 500.88778686523, 0, 0, 90);
	CreateDynamicObject(2591, 1974.0999755859, -1470.0500488281, 500.88778686523, 0, 0, 0);
	CreateDynamicObject(2591, 1975.8199462891, -1468.2974853516, 500.88778686523, 0, 0, 90);
	CreateDynamicObject(2591, 1979.2700195313, -1468.2889404297, 500.88778686523, 0, 0, 90);
	CreateDynamicObject(2591, 1974.0999755859, -1466.6171875, 500.88778686523, 0, 0, 0);
	CreateDynamicObject(1491, 1974.0576171875, -1463.3699951172, 498.18591308594, 0, 0, 270);
	CreateDynamicObject(2591, 1974.0999755859, -1461.6390380859, 500.88778686523, 0, 0, 0);
	CreateDynamicObject(2591, 1975.8499755859, -1459.8922119141, 500.88778686523, 0, 0, 90);
	CreateDynamicObject(2591, 1979.2758789063, -1459.8891601563, 500.88778686523, 0, 0, 90);
	CreateDynamicObject(14867, 1967.9892578125, -1470.2998046875, 499.70001220703, 0, 0, 270);
	CreateDynamicObject(2591, 1974.0999755859, -1458.1850585938, 500.88778686523, 0, 0, 0);
	CreateDynamicObject(1491, 1974.0029296875, -1454.9399414063, 498.20001220703, 0, 0, 270);
	CreateDynamicObject(2591, 1974.0600585938, -1453.2099609375, 500.88778686523, 0, 0, 0);
	CreateDynamicObject(3383, 1978.3972167969, -1479.5216064453, 498.18591308594, 0, 0, 90);
	CreateDynamicObject(3389, 1978.5628662109, -1482.8884277344, 498.18591308594, 0, 0, 0);
	CreateDynamicObject(3383, 1978.4248046875, -1472.1331787109, 498.18591308594, 0, 0, 90);
	CreateDynamicObject(3389, 1978.3178710938, -1475.3507080078, 498.18591308594, 0, 0, 0);
	CreateDynamicObject(3383, 1978.5854492188, -1463.1412353516, 498.18591308594, 0, 0, 90);
	CreateDynamicObject(3389, 1978.6572265625, -1466.646484375, 498.18591308594, 0, 0, 0);
	CreateDynamicObject(1502, 1967.4000244141, -1481.8260498047, 498.17810058594, 0, 0, 270);
	CreateDynamicObject(3383, 1977.9801025391, -1455.0395507813, 498.18591308594, 0, 0, 90);
	CreateDynamicObject(3389, 1978.0191650391, -1458.4385986328, 498.18591308594, 0, 0, 0);
	CreateDynamicObject(1491, 1971.2998046875, -1448.9794921875, 498.18591308594, 0, 0, 270);
	CreateDynamicObject(1491, 1971.3056640625, -1447.2926025391, 498.18591308594, 0, 0, 270);
	CreateDynamicObject(2591, 1973.0925292969, -1445.4769287109, 500.88778686523, 0, 0, 90);
	CreateDynamicObject(2591, 1973.04296875, -1448.88671875, 500.88778686523, 0, 0, 90);
	CreateDynamicObject(2591, 1973.099609375, -1447.216796875, 500.88778686523, 0, 0, 90);
	CreateDynamicObject(1491, 1971.28515625, -1445.57421875, 498.18591308594, 0, 0, 270);
	CreateDynamicObject(2591, 1973.0999755859, -1443.7663574219, 500.88778686523, 0, 0, 90);
	CreateDynamicObject(2528, 1973.630859375, -1449.6511230469, 498.18591308594, 0, 0, 270);
	CreateDynamicObject(2528, 1973.6126708984, -1448.0812988281, 498.18591308594, 0, 0, 270);
	CreateDynamicObject(2602, 1973.8011474609, -1439.1119384766, 498.70935058594, 0, 0, 0);
	CreateDynamicObject(1491, 1971.2991943359, -1443.8299560547, 498.18591308594, 0, 0, 270);
	CreateDynamicObject(2591, 1973, -1438.599609375, 500.88778686523, 0, 0, 90);
	CreateDynamicObject(2591, 1971.3426513672, -1441.9733886719, 500.88778686523, 0, 0, 0);
	CreateDynamicObject(1491, 1971.2021484375, -1438.69921875, 498.18591308594, 0, 0, 270);
	CreateDynamicObject(2528, 1973.775390625, -1444.5419921875, 498.18591308594, 0, 0, 270);
	CreateDynamicObject(2528, 1973.8732910156, -1446.3562011719, 498.18591308594, 0, 0, 270);
	CreateDynamicObject(2371, 1942.0511474609, -1465.7760009766, 498.18591308594, 0, 0, 90);
	CreateDynamicObject(2389, 1941.9522705078, -1465.1287841797, 498.79998779297, 0, 0, 180);
	CreateDynamicObject(2389, 1940.8813476563, -1465.1199951172, 498.79998779297, 0, 0, 179.99450683594);
	CreateDynamicObject(2395, 1943.8890380859, -1466.4953613281, 498.18591308594, 0, 0, 270);
	CreateDynamicObject(2395, 1944.0899658203, -1469.2478027344, 498.1780090332, 0, 0, 90);
	CreateDynamicObject(1502, 1937.1214599609, -1463.0300292969, 498.20001220703, 0, 0, 270);
	CreateDynamicObject(2947, 1934.9206542969, -1526.8299560547, 498.18786621094, 0, 0, 270);
	CreateDynamicObject(1502, 1945.5484619141, -1450.9300537109, 498.20001220703, 0, 0, 0);
	CreateDynamicObject(1745, 1942.5014648438, -1438.1943359375, 498.17810058594, 0, 0, 90);
	CreateDynamicObject(1745, 1942.5100097656, -1442.1536865234, 498.17810058594, 0, 0, 90);
	CreateDynamicObject(1745, 1942.5999755859, -1445.9000244141, 498.17810058594, 0, 0, 90);
	CreateDynamicObject(1745, 1944.6154785156, -1437.3210449219, 498.17810058594, 0, 0, 270);
	CreateDynamicObject(1745, 1944.7553710938, -1440.9621582031, 498.17810058594, 0, 0, 270);
	CreateDynamicObject(1745, 1944.6693115234, -1445, 498.17810058594, 0, 0, 270);
	CreateDynamicObject(1811, 1914.1381835938, -1496.0422363281, 498.8141784668, 0, 0, 179.99450683594);
	CreateDynamicObject(1502, 1934.0400390625, -1450.890625, 498.18591308594, 0, 0, 0);
	CreateDynamicObject(2399, 1940.8508300781, -1466.3403320313, 498.7799987793, 0, 0, 0);
	CreateDynamicObject(2399, 1941.9650878906, -1466.3254394531, 498.7799987793, 0, 0, 0);
	CreateDynamicObject(2605, 1930.4365234375, -1444.6778564453, 498.58435058594, 0, 0, 180);
	CreateDynamicObject(1714, 1930.2830810547, -1443.1826171875, 498.18591308594, 0, 0, 0);
	CreateDynamicObject(1671, 1930.9105224609, -1446.0375976563, 498.64611816406, 0, 0, 180);
	CreateDynamicObject(1671, 1929.7565917969, -1446.0155029297, 498.64611816406, 0, 0, 179.99450683594);
	CreateDynamicObject(2606, 1938.2681884766, -1443.9865722656, 500.64868164063, 0, 0, 270);
	CreateDynamicObject(2164, 1938.2681884766, -1446.9564208984, 498.17999267578, 0, 0, 270);
	CreateDynamicObject(2163, 1938.2681884766, -1448.7110595703, 498.19000244141, 0, 0, 270);
	CreateDynamicObject(1235, 1928.9434814453, -1443.4281005859, 498.68899536133, 0, 0, 29.99267578125);
	CreateDynamicObject(1703, 1932, -1450, 498.18591308594, 0, 0, 179.99450683594);
	CreateDynamicObject(2690, 1935.0279541016, -1442.9899902344, 500.11514282227, 0, 0, 1);
	CreateDynamicObject(1523, 1963.5, -1450.9000244141, 498.20001220703, 0, 0, 0);
	CreateDynamicObject(1663, 1936.8739013672, -1504.9721679688, 498.64807128906, 0, 0, 180);
	CreateDynamicObject(1663, 1937.7625732422, -1504.9599609375, 498.65490722656, 0, 0, 179.99450683594);
	CreateDynamicObject(1663, 1938.623046875, -1504.9699707031, 498.65490722656, 0, 0, 179.99450683594);
	CreateDynamicObject(1663, 1939.4991455078, -1504.9461669922, 498.65490722656, 0, 0, 179.99450683594);
	CreateDynamicObject(1491, 1971.1860351563, -1436.9699707031, 498.18591308594, 0, 0, 270);
	CreateDynamicObject(2591, 1972.9990234375, -1436.8499755859, 500.88778686523, 0, 0, 90);
	CreateDynamicObject(2528, 1973.8322753906, -1437.7016601563, 498.18591308594, 0, 0, 270);
	CreateDynamicObject(2523, 1961.4678955078, -1447.6217041016, 498.18591308594, 0, 0, 90);
	CreateDynamicObject(2523, 1961.5109863281, -1444.2700195313, 498.18591308594, 0, 0, 90);
	CreateDynamicObject(2523, 1961.5350341797, -1441.0617675781, 498.18591308594, 0, 0, 90);
	CreateDynamicObject(2523, 1965.7807617188, -1437.0657958984, 498.18591308594, 0, 0, 0);
	CreateDynamicObject(2614, 1930.3646240234, -1443.1295166016, 500.75918579102, 0, 0, 0);
	// San Andreas News by Ivanobishev.
	CreateDynamicObject(1250, 782.5, -1384.4000244141, 13.699999809265, 0, 0, 270);
	CreateDynamicObject(1250, 773.40002441406, -1330.5989990234, 13.60000038147, 0, 0, 90);
	CreateDynamicObject(1237, 771.70001220703, -1325.5999755859, 12.5, 0, 0, 0);
	CreateDynamicObject(1237, 783.69921875, -1326, 12.5, 0, 0, 0);
	CreateDynamicObject(1251, 778.099609375, -1324.8994140625, 12.329999923706, 0, 90, 88.698120117188);
	CreateDynamicObject(3934, 738, -1370, 24.700000762939, 0, 0, 0);
	CreateDynamicObject(3526, 743.90002441406, -1370.0999755859, 24.799999237061, 0, 0, 0);
	CreateDynamicObject(3526, 737.90002441406, -1365.1999511719, 24.799999237061, 0, 0, 90);
	CreateDynamicObject(3526, 732.70001220703, -1370, 24.799999237061, 0, 0, 180);
	CreateDynamicObject(3526, 738.09997558594, -1374.8000488281, 24.799999237061, 0, 0, 270);
	CreateDynamicObject(11544, 733.21997070313, -1366, 24.798999786377, 0, 0, 180);
	CreateDynamicObject(1251, 778.09600830078, -1326.3000488281, 12.494999885559, 0, 90, 88.698120117188);
	CreateDynamicObject(996, 778.90002441406, -1340, 13.300000190735, 0, 0, 0);
	CreateDynamicObject(996, 778.90002441406, -1345, 13.300000190735, 0, 0, 0);
	CreateDynamicObject(996, 778.90002441406, -1350, 13.300000190735, 0, 0, 0);
	CreateDynamicObject(996, 778.90002441406, -1355, 13.300000190735, 0, 0, 0);
	CreateDynamicObject(996, 778.90002441406, -1360, 13.300000190735, 0, 0, 0);
	CreateDynamicObject(996, 778.90002441406, -1365, 13.39999961853, 0, 0, 0);
	CreateDynamicObject(1251, 778.5, -1344.9899902344, 12.474439620972, 0, 90, 359.89562988281);
	CreateDynamicObject(1533, 732.09997558594, -1348.8000488281, 12.590000152588, 0, 0, 90);
	CreateDynamicObject(1533, 732.09997558594, -1347.2879638672, 12.590000152588, 0, 0, 90);
	CreateDynamicObject(1237, 778.79998779297, -1339, 12.5, 0, 0, 0);
	CreateDynamicObject(1237, 778.79998779297, -1365.8000488281, 12.5, 0, 0, 0);
	CreateDynamicObject(1597, 758.90002441406, -1344.0999755859, 15.199999809265, 0, 0, 0);
	CreateDynamicObject(1364, 760.29998779297, -1331.0999755859, 13.300000190735, 0, 0, 0);
	CreateDynamicObject(997, 771.70001220703, -1329.5999755859, 12.5, 0, 0, 90);
	CreateDynamicObject(997, 783.70001220703, -1329.9000244141, 12.5, 0, 0, 90);
	// ATMs by Acedio.
	CreateDynamicObject(2942, 1336.95, -1745, 13.2, 0, 0, 90);
	CreateDynamicObject(2942, 1834.2, -1851, 13, 0, 0, 0);
	CreateDynamicObject(2942, 1151.6, -1385.5, 13.4, 0, 0, 0);
	CreateDynamicObject(2942, 560.90002, -1293.999, 16.89, 0, 0, 180);
	// Unity Station fences by Acedio.
	CreateDynamicObject(970, 1827, -1838.4, 13.1, 0, 0, 89.3);
	CreateDynamicObject(970, 1826.95, -1842.5, 13.1, 0, 0, 89.297);
	CreateDynamicObject(970, 1826.9, -1846.6, 13.1, 0, 0, 89.297);
	CreateDynamicObject(970, 1826.84, -1850.7, 13.1, 0, 0, 89.297);
	// Florist shop interior by Acedio.
	CreateDynamicObject(14593, 162.8, -186.10001, -10, 0, 0, 0);
	CreateDynamicObject(3089, 168.75999, -193.3, -11, 0, 0, 0);
	CreateDynamicObject(948, 171.39999, -192.89999, -12.3, 0, 0, 0);
	CreateDynamicObject(949, 167.10001, -190, -11.7, 0, 0, 0);
	CreateDynamicObject(950, 164.10001, -189.8, -10.7, 0, 0, 0);
	CreateDynamicObject(3383, 160.8, -189.8, -12.3, 0, 0, 0);
	CreateDynamicObject(3383, 164.39999, -189.8, -12.3, 0, 0, 0);
	CreateDynamicObject(1616, 171.5, -193.2, -8, 0, 0, 0);
	CreateDynamicObject(1843, 171.3, -191, -12.3, 0, 0, 270);
	CreateDynamicObject(1844, 171.3, -188, -12.3, 0, 0, 270);
	CreateDynamicObject(1845, 171.3, -185.10001, -12.3, 0, 0, 270);
	CreateDynamicObject(1847, 169.3, -172.60001, -12.3, 0, 0, 0);
	CreateDynamicObject(1847, 164.2, -172.60001, -12.3, 0, 0, 0);
	CreateDynamicObject(1847, 159.2, -172.60001, -12.3, 0, 0, 0);
	CreateDynamicObject(1973, 156.2, -172.60001, -11.7, 0, 0, 0);
	CreateDynamicObject(1973, 154.7, -172.60001, -11.7, 0, 0, 0);
	CreateDynamicObject(2362, 159.39999, -178.8, -11.3, 0, 0, 0);
	CreateDynamicObject(2412, 168.8, -192.7, -12.3, 0, 0, 0);
	CreateDynamicObject(2412, 170.8, -192.39999, -12.2, 0, 0, 0);
	CreateDynamicObject(2436, 164.3, -175.89999, -12.3, 0, 0, 0);
	CreateDynamicObject(2436, 162.7, -175.89999, -12.3, 0, 0, 0);
	CreateDynamicObject(2436, 161.10001, -175.89999, -12.3, 0, 0, 0);
	CreateDynamicObject(2440, 159.8, -178.7, -12.3, 0, 0, 0);
	CreateDynamicObject(2439, 158.8, -178.7, -12.3, 0, 0, 0);
	CreateDynamicObject(2439, 157.8, -178.7, -12.3, 0, 0, 0);
	CreateDynamicObject(2439, 156.8, -178.7, -12.3, 0, 0, 0);
	CreateDynamicObject(1576, 154, -172.7, -12.1, 0, 0, 0);
	CreateDynamicObject(1576, 154.8, -172.7, -12.1, 0, 0, 0);
	CreateDynamicObject(1576, 155.60001, -172.7, -12.1, 0, 0, 0);
	CreateDynamicObject(1576, 156.2, -172.7, -12.1, 0, 0, 0);
	CreateDynamicObject(1576, 156, -172.7, -11.99, 0, 0, 0);
	CreateDynamicObject(337, 160.5, -176, -12.1, 0, 0, 0);
	CreateDynamicObject(2228, 167.10001, -189.7, -11.8, 0, 0, 0);
	CreateDynamicObject(2228, 165.3, -188.89999, -11.8, 0, 0, 0);
	CreateDynamicObject(2228, 164.89999, -188.89999, -11.8, 0, 0, 0);
	CreateDynamicObject(2228, 164.5, -188.89999, -11.8, 0, 0, 0);
	CreateDynamicObject(2237, 164, -189, -11.2, 0, 0, 0);
	CreateDynamicObject(2237, 163.60001, -189, -11.2, 0, 0, 0);
	CreateDynamicObject(2237, 163.2, -189, -11.2, 0, 0, 0);
	CreateDynamicObject(2895, 165, -189.7, -11, 0, 0, 0);
	CreateDynamicObject(325, 161, -189.5, -11, 0, 0, 0);
	CreateDynamicObject(2901, 160, -189.39999, -10.8, 0, 0, 0);
	CreateDynamicObject(1514, 157.10001, -178.8, -11, 0, 0, 0);
	CreateDynamicObject(1885, 167.2, -181.39999, -12.3, 0, 0, 0);
	// Prison playground by Ivanobishev.
	CreateDynamicObject(991, 1814.1, -1540.14, 16.5, 0, 0, 355);
	CreateDynamicObject(14791, 1754.7, -1536.6, 10.4, 0, 0, 0);
	CreateDynamicObject(2933, 1753.8, -1582.58, 13.4, 0, 0, 168);
	// Prison interior by Acedio.
	CreateDynamicObject(14408, 1789.4004, -1538.5996, -5, 0, 0, 0);
	CreateDynamicObject(14411, 1776.9489, -1560, -17.5, 0, 0, 180);
 	CreateDynamicObject(5020, 1811.4, -1550.6, -6.3, 0, 0, 0);
	CreateDynamicObject(4100, 1799.4, -1535, -12.6, 0, 0, 49.9);
	CreateDynamicObject(1617, 1799.1, -1546.8, -9.5, 0, 0, 0);
	CreateDynamicObject(958, 1801.2, -1551.9, -10.6, 0, 0, 0);
	CreateDynamicObject(1687, 1804.5, -1552.1, -10.7, 0, 0, 0);
	CreateDynamicObject(939, 1808.3, -1526.3, -11.9, 0, 0, 0);
	CreateDynamicObject(942, 1802.8, -1526.3, -11.9, 0, 0, 0);
	CreateDynamicObject(935, 1810.6, -1528.2, -13.8, 0, 0, 0);
	CreateDynamicObject(2774, 1774.6, -1549.9, -5, 0, 0, 0);
	CreateDynamicObject(14843, 1793.2, -1549.3, -13.1, 0, 0, 0);
	CreateDynamicObject(14843, 1780.3, -1549.4, -13.1, 0, 0, 0);
	CreateDynamicObject(14843, 1768.5, -1549.4, -13.1, 0, 0, 0);
	CreateDynamicObject(2774, 1787, -1549.9, -10, 0, 0, 0);
	CreateDynamicObject(14843, 1793.2, -1549.2, -10.52, 0, 0, 0);
	CreateDynamicObject(14843, 1780.8, -1549.3, -10.52, 0, 0, 0);
	CreateDynamicObject(14843, 1768.4, -1549.3, -10.52, 0, 0, 0);
	CreateDynamicObject(994, 1792.8, -1547.4, -11.6, 0, 0, 0);
	CreateDynamicObject(994, 1786.5, -1547.4, -11.6, 0, 0, 0);
	CreateDynamicObject(994, 1780.2, -1547.4, -11.6, 0, 0, 0);
	CreateDynamicObject(994, 1773.9, -1547.4, -11.6, 0, 0, 0);
	CreateDynamicObject(994, 1767.6, -1547.4, -11.6, 0, 0, 0);
	CreateDynamicObject(1968, 1773, -1528.6, -13.8, 0, 0, 0);
	CreateDynamicObject(2165, 1801.1, -1528.4, -8, 0, 0, 180);
	CreateDynamicObject(2166, 1803, -1527.4, -8, 0, 0, 180);
	CreateDynamicObject(2174, 1800, -1525.3, -8, 0, 0, 0);
	CreateDynamicObject(2310, 1800.7, -1525.5, -7.5, 0, 0, 270);
	CreateDynamicObject(2356, 1800.6, -1527.1, -8, 0, 0, 180);
	CreateDynamicObject(2387, 1809.6, -1531.1, -8, 0, 0, 0);
	CreateDynamicObject(2412, 1810.6, -1548.5, -8, 0, 0, 90);
	CreateDynamicObject(2412, 1810.6, -1551.9, -8, 0, 0, 90);
	CreateDynamicObject(2612, 1800.7, -1524.9, -5.6, 0, 0, 0);
	CreateDynamicObject(1616, 1811.2, -1552, -3.9, 0, 0, 0);
	CreateDynamicObject(1616, 1799.1, -1547.1, -7.2, 0, 0, 0);
	CreateDynamicObject(1613, 1799.1, -1526.8, -3.7, 0, 0, 0);
	CreateDynamicObject(2397, 1809.8, -1531.8, -7.5, 0, 0, 0);
	CreateDynamicObject(1778, 1806.4, -1548.2, -14.3, 0, 0, 0);
	CreateDynamicObject(1789, 1805.8, -1549.2, -13.8, 0, 0, 0);
	CreateDynamicObject(7191, 1785.6, -1549.3, -11.8, 0, 90, 90);
	CreateDynamicObject(7191, 1785, -1551.2, -11.81, 0, 90, 90);
	CreateDynamicObject(7191, 1785, -1550.98999, -9.2, 0, 90, 90);
	CreateDynamicObject(2885, 1794.5, -1554, -7.6, 0, 0, 90);
	CreateDynamicObject(2885, 1786.4, -1555, -7.6, 0, 0, 90);
	CreateDynamicObject(2885, 1774, -1555, -7.6, 0, 0, 90);
	CreateDynamicObject(3294, 1762.9, -1538.9, -11.4, 0, 0, 0);
	CreateDynamicObject(4100, 1799.3, -1536.9, -5.5, 0, 0, 49.9);
	CreateDynamicObject(1235, 1763.7, -1535.9, -13.8, 0, 0, 0);
	CreateDynamicObject(1343, 1763.6, -1536.7, -13.6, 0, 0, 90);
	CreateDynamicObject(11544, 1765.8, -1548.8, -12.75, 0, 0, 180);
	CreateDynamicObject(1968, 1773, -1527.2, -13.8, 0, 0, 0);
	CreateDynamicObject(1968, 1770, -1528.6, -13.8, 0, 0, 0);
	CreateDynamicObject(1968, 1770, -1527.2, -13.8, 0, 0, 0);
	CreateDynamicObject(1968, 1773, -1531.5, -13.8, 0, 0, 0);
	CreateDynamicObject(1968, 1770, -1531.5, -13.8, 0, 0, 0);
	CreateDynamicObject(1969, 1776.5, -1528, -13.8, 0, 0, 0);
	CreateDynamicObject(1969, 1776.7, -1531.5, -13.8, 0, 0, 0);
	CreateDynamicObject(4642, 1764.3, -1529, -12.6, 0, 0, 0);
	CreateDynamicObject(4642, 1765, -1526.4, -12.6, 0, 0, 270);
	CreateDynamicObject(2350, 1766.6, -1525.7, -14, 0, 0, 0);
	CreateDynamicObject(2686, 1764.9, -1530.3, -12.1, 0, 0, 0);
	CreateDynamicObject(2685, 1765.3, -1530.3, -12.1, 0, 0, 0);
	CreateDynamicObject(2687, 1764.9, -1530.3, -12.7, 0, 0, 0);
	CreateDynamicObject(2766, 1766.1, -1524.9, -10.3, 0, 0, 0);
	CreateDynamicObject(14409, 1808.9, -1542, -11.2, 0, 0, 0);
	prisondoor = CreateDynamicObject(5422, 1799.2998, -1546.7002, -12.3, 0, 0, 0);
	CreateDynamicObject(1771, 1798.3, -1551, -13.7, 0, 0, 0);
	CreateDynamicObject(1771, 1793.5, -1550.9, -13.7, 0, 0, 0);
	CreateDynamicObject(1771, 1785.3, -1551, -13.7, 0, 0, 0);
	CreateDynamicObject(1771, 1772.9, -1550.9, -13.7, 0, 0, 0);
	CreateDynamicObject(1771, 1764, -1550.8, -13.7, 0, 0, 0);
	CreateDynamicObject(1771, 1797.9, -1550.8, -11.1, 0, 0, 0);
	CreateDynamicObject(1771, 1793.4, -1550.8, -11.1, 0, 0, 0);
	CreateDynamicObject(1771, 1785.5, -1550.9, -11.1, 0, 0, 0);
	CreateDynamicObject(1771, 1763.9, -1550.9, -11.1, 0, 0, 0);
	CreateDynamicObject(1771, 1773.1, -1550.9, -11.1, 0, 0, 0);
	CreateDynamicObject(2525, 1787.5, -1551.5, -11.7, 0, 0, 90);
	CreateDynamicObject(2525, 1775, -1551.6, -11.7, 0, 0, 90);
	CreateDynamicObject(2525, 1795.4, -1551.8, -14.3, 0, 0, 90);
	CreateDynamicObject(2525, 1787.3, -1551.5, -14.3, 0, 0, 90);
	CreateDynamicObject(2525, 1795.4, -1551.7, -11.7, 0, 0, 90);
	CreateDynamicObject(2525, 1775.4, -1551.6, -14.3, 0, 0, 90);
	CreateDynamicObject(2525, 1768, -1551.9, -11.7, 0, 0, 180);
	CreateDynamicObject(2525, 1768.2, -1551.9, -14.3, 0, 0, 179.995);
	CreateDynamicObject(14791, 1792.7, -1534.4, -12.3, 0, 0, 45);
	CreateDynamicObject(14782, 1807.9, -1525.3, -7, 0, 0, 0);
	CreateDynamicObject(11245, 1799.5, -1549.1, -3.9, 0, 0, 0);
	CreateDynamicObject(1810, 1789.2, -1529.2, -14.3, 0, 0, 45);
	CreateDynamicObject(1810, 1788.7, -1530.8, -14.3, 0, 0, 90);
	CreateDynamicObject(1810, 1791.7, -1528.8, -14.3, 0, 0, 0);
	CreateDynamicObject(2957, 1795.3, -1524.8, -12.7, 0, 0, 0);
	CreateDynamicObject(2957, 1795.3, -1524.8, -9.5, 0, 0, 0);
	// Garbage bags and containers by Ivanobishev.
	CreateDynamicObject(1372, 2092, -1828.2, 12.6, 0, 0, 270); // contenedor
	CreateDynamicObject(1372, 2269.8, -1755.1, 12.5, 0, 0, 180);
	CreateDynamicObject(1372, 2633.2, -1938.7, 12.5, 0, 0, 180);
	basuraUno = CreateDynamicObject(1440, 2090.2, -1829.3, 13.1, 0, 0, 90);
	basuraDos = CreateDynamicObject(1440, 2270, -1753.1, 12.9, 0, 0, 0);
	basuraTres = CreateDynamicObject(1440, 2633.5, -1936.6, 12.9, 0, 0, 0);
	basuraSuelo = CreateDynamicObject(2672, 1418.2, -1646.4, 12.7, 0, 0, 0);
	// Bus stops by Acedio.
	CreateDynamicObject(1257, 1613.2, -2326.2, -2.4, 0, 0, 270);
	CreateDynamicObject(1257, 1972.7, -2048, 13.8, 0, 0, 0);
	CreateDynamicObject(1257, 2096.3999, -1769.3, 13.8, 0, 0, 344);
	CreateDynamicObject(1257, 2080.2, -1180.7, 24.1, 0, 0, 0);
	CreateDynamicObject(1257, 1500.1, -1026.2, 24.1, 0, 0, 85);
	CreateDynamicObject(1257, 933.79999, -1132.5, 24.1, 0, 0, 90);
	CreateDynamicObject(1257, 566.90002, -1220.1, 17.9, 0, 0, 115);
	CreateDynamicObject(1257, 520.59998, -1556.7, 16.3, 0, 0, 180);
	CreateDynamicObject(1257, 656.40002, -1763.1, 13.8, 0, 0, 255);
	// Intersections by Acedio.
	CreateDynamicObject(9093, 1757, -2186.1001, 12.56, 0, 90, 0);
	CreateDynamicObject(9093, 1757, -2178.8, 12.56, 0, 90, 0);
	CreateDynamicObject(9093, 1760.4, -2186.1001, 12.56, 0, 90, 180);
	CreateDynamicObject(9093, 1760.4, -2178.8, 12.56, 0, 90, 180);
	CreateDynamicObject(994, 1762.3, -2181.3999, 12.6, 0, 0, 90);
	CreateDynamicObject(994, 1762.3, -2187.7, 12.5, 0, 0, 90);
	CreateDynamicObject(994, 1755.1, -2181.3999, 12.6, 0, 0, 90);
	CreateDynamicObject(994, 1755.1, -2187.7, 12.5, 0, 0, 90);
	CreateDynamicObject(9093, 1054, -1855.4, 12.6, 0, 90, 90);
	CreateDynamicObject(9093, 1054, -1849.7, 12.6, 0, 90, 270);
	CreateDynamicObject(994, 1050.8, -1857.4, 12.4, 0, 0, 0);
	CreateDynamicObject(994, 1050.7, -1847.7, 12.4, 0, 0, 0);
	CreateDynamicObject(3037, 631, -1738.4, 12.51, 0, 270, 80);
	CreateDynamicObject(3037, 621, -1736.6, 12.56, 0.6, 270, 79.997);
	CreateDynamicObject(997, 636, -1741, 12.5, 0, 0, 80);
	CreateDynamicObject(997, 615.5, -1737.3, 12.6, 0, 0, 79.997);
	CreateDynamicObject(1324, 636.79999, -1739.5, 14, 0, 0, 0);
	CreateDynamicObject(1324, 615.40002, -1735.6, 14.2, 0, 0, 180);
	// West tolls by Ivanobishev.
	CreateDynamicObject(966, 65.3369140625, -1529.4228515625, 3.9186687469482, 0, 0, 270);
	CreateDynamicObject(1237, 65.314453125, -1530.3955078125, 3.9291739463806, 0, 0, 0);
	CreateDynamicObject(1237, 65.432144165039, -1521.8427734375, 4.0904111862183, 0, 0, 0);
	CreateDynamicObject(4638, 63.031761169434, -1532.3758544922, 5.8676452636719, 0, 0, 350.98999023438);
	CreateDynamicObject(966, 36.421127319336, -1533.8541259766, 4.2416791915894, 0, 0, 90);
	CreateDynamicObject(1237, 36.398139953613, -1532.8818359375, 4.2418360710144, 0, 0, 0);
	CreateDynamicObject(1237, 36.329917907715, -1541.4851074219, 4.2442235946655, 0, 0, 0);
	CreateDynamicObject(4638, 38.973503112793, -1530.7833251953, 6.1047353744507, 0, 0, 172);
	CreateDynamicObject(982, 52.057506561279, -1528.8887939453, 4.9615297317505, 0, 0, 80);
	CreateDynamicObject(982, 50.2705078125, -1533.9189453125, 4.828980922699, 0, 0, 81.996459960938);
	CreateDynamicObject(1228, 64.14803314209, -1534.9545898438, 4.5947670936584, 0, 0, 351);
	CreateDynamicObject(1228, 37.616218566895, -1527.9885253906, 4.8418784141541, 0, 0, 350.99670410156);
	CreateDynamicObject(979, 80.900253295898, -1520.0989990234, 4.5535182952881, 0, 0, 205);
	CreateDynamicObject(979, 80.900100708008, -1520.0980224609, 4.5500001907349, 0, 0, 204.99938964844);
	CreateDynamicObject(1616, 40.317111968994, -1531.6883544922, 8.3560276031494, 0, 0, 66);
	CreateDynamicObject(1616, 61.679439544678, -1531.4136962891, 8.1114072799683, 0, 0, 250);
	Puertapeaje1 = CreateDynamicObject(968, 65.339996337891, -1529.5, 4.8000001907349, 0, 90, 90);
	Puertapeaje2 = CreateDynamicObject(968, 36.400001525879, -1533.8000488281, 5.0999999046326, 0, 90, 270);
	// Little Italy by Ivanobishev.
	CreateDynamicObject(1342, 2653.6999511719, -1421.5999755859, 30.39999961853, 0, 0, 179.99450683594); // noodles stand
	CreateDynamicObject(1341, 2653.69921875, -1429.5, 30.39999961853, 0, 0, 179.99450683594); // ice cream stand
	CreateDynamicObject(3855, 2647.8999023438, -1414.9000244141, 29.299999237061, 0, 0, 0); // traffic light with rainbow flag
	CreateDynamicObject(3855, 2637.6000976563, -1393.0999755859, 29.39999961853, 0, 0, 180);
	CreateDynamicObject(1352, 2652.4951, -1398.6830, 29.35, 0, 0,90); // other traffic light
	CreateDynamicObject(2764, 2635.1000976563, -1415.4000244141, 29.799999237061, 0, 0, 0); // table
	CreateDynamicObject(2764, 2635.6999511719, -1408.5, 29.799999237061, 0, 0, 0);
	CreateDynamicObject(2807, 2636.3898925781, -1415.4000244141, 29.89999961853, 0, 0, 0); // chair
	CreateDynamicObject(2807, 2635.1000976563, -1416.6999511719, 29.89999961853, 0, 0, 270);
	CreateDynamicObject(2807, 2633.7700195313, -1415.3549804688, 30, 0, 0, 180);
	CreateDynamicObject(2807, 2635.169921875, -1414.0300292969, 29.89999961853, 0, 0, 90);
	CreateDynamicObject(2807, 2635.6999511719, -1407.1999511719, 29.89999961853, 0, 0, 90);
	CreateDynamicObject(2807, 2637.1000976563, -1408.5, 29.89999961853, 0, 0, 0);
	CreateDynamicObject(2807, 2634.3000488281, -1408.5999755859, 30, 0, 0, 179.99450683594);
	CreateDynamicObject(2807, 2635.6999511719, -1409.8000488281, 29.89999961853, 0, 0, 270);
	// Some traffic signs by Ivanobishev.
	CreateDynamicObject(19967,1761.2651,-1454.6771,12.6,0,0,180); // Idlewood freeway, do not enter
	CreateDynamicObject(19967,2048.7866,-1602.1786,12.542,0,0,0); // Idelwood freeway, do not enter
	CreateDynamicObject(19949,1322.2596,-1726.2600,11.8,0,0,90); // Pershing Square do not go to left
	CreateDynamicObject(19956,1322.2596,-1726.2600,12.5,0,0,90); // Pershing Square turn right
	CreateDynamicObject(19966,2348.8894,-1668.6631,12.3,0,0,0); // Ganton stop
	// Northern Pershing Square traffic lights by Ivanobishev.
	CreateDynamicObject(1315,1464.4752,-1435.1670,15.4,0,0,90);
	CreateDynamicObject(1315,1445.2466,-1447.1672,15.4,0,0,270);
	CreateDynamicObject(1315,1448.7538,-1431.0695,15.4,0,0,180);
	CreateDynamicObject(1315,1460.6190,-1450.9165,15.4,0,0,0);
	// Central Pershing Square traffic lights by Ivanobishev.
	CreateDynamicObject(1315,1423.4944,-1582.4338,15.4,0,0,180);
	CreateDynamicObject(1315,1435.7837,-1602.0002,15.4,0,0,0);
	CreateDynamicObject(1315,1439.2314,-1586.3811,15.4,0,0,90);
	CreateDynamicObject(1315,1419.6162,-1598.3497,15.4,0,0,270);
	// Near Blueberry port by Acedio.
	// CreateDynamicObject(12990, -65.2, -579.79999, 1.2, 0, 0, 0);
	// CreateDynamicObject(1461, -67.4, -593.70001, 2.4, 0, 0, 180);
	// CreateDynamicObject(16105, -60.8, -572.40002, 3, 0, 0, 90);
	return 1;
}

public OnGameModeExit()
{
    KillTimer(synctimer);
    KillTimer(othtimer);
    KillTimer(checkgastimer);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SpawnPlayer(playerid); // Spawn after death.
	return 1;
}

public OnPlayerConnect(playerid)
{
    PlayerInfo[playerid][Admin] = -1;
    PlayerInfo[playerid][RolePoints] = 0;
    PlayerInfo[playerid][Bank] = 0;
    PlayerInfo[playerid][Money] = 0;
    PlayerInfo[playerid][Level] = 0;
    PlayerInfo[playerid][Hours] = 0;
    PlayerInfo[playerid][Sex] = 0;
    PlayerInfo[playerid][Age] = 0;
    PlayerInfo[playerid][PhoneNumber] = 0;
    PlayerInfo[playerid][Pos_x] = 1642.4110;
    PlayerInfo[playerid][Pos_y] = -2335.0168;
    PlayerInfo[playerid][Pos_z] = -2.6797;
    PlayerInfo[playerid][Interior] = 0;
    PlayerInfo[playerid][VirtualWorld] = 0;
    PlayerInfo[playerid][Skin] = 26;
    PlayerInfo[playerid][Job] = 0;
    PlayerInfo[playerid][Faction] = 0;
    PlayerInfo[playerid][Rank] = 0;
    PlayerInfo[playerid][HouseKey] = 0;
    PlayerInfo[playerid][BusinessKey] = 0;
    PlayerInfo[playerid][VehicleKey] = 0;
    PlayerInfo[playerid][VehicleKey2] = 0;
    PlayerInfo[playerid][LottoNumber] = 0;
    PlayerInfo[playerid][CriminalSkill] = 0;
    PlayerInfo[playerid][Prison] = 0;
    PlayerInfo[playerid][Licence] = 0;
    PlayerInfo[playerid][Dead] = 0;
    PlayerInfo[playerid][One] = 0;
    PlayerInfo[playerid][OneAmount] = 0;
    PlayerInfo[playerid][Two] = 0;
    PlayerInfo[playerid][TwoAmount] = 0;
    PlayerInfo[playerid][Three] = 0;
    PlayerInfo[playerid][ThreeAmount] = 0;
    PlayerInfo[playerid][Four] = 0;
    PlayerInfo[playerid][FourAmount] = 0;
    PlayerInfo[playerid][Five] = 0;
    PlayerInfo[playerid][FiveAmount] = 0;
    PlayerInfo[playerid][Hand] = 0;
    PlayerInfo[playerid][HandAmount] = 0;
    PlayerInfo[playerid][Back] = 0;
    PlayerInfo[playerid][BackAmount] = 0;
    // Variables.
    Call[playerid] = -1;
    //
    TogglePlayerSpectating(playerid, 1);
    new string[128];
    new plname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, plname, sizeof(plname));
    format(string, sizeof(string), "users/%s.ini", plname);
    if(fexist(string))
    {
  		new loginstring[128];
	 	new loginname[64];
 		GetPlayerName(playerid,loginname,sizeof(loginname));
	 	format(loginstring,sizeof(loginstring),"Welcome, %s.\n\nWrite your password:",loginname);
	 	ShowPlayerDialog(playerid, 4, DIALOG_STYLE_PASSWORD,"Logging in",loginstring,"Submit","Exit");
		SendClientMessage(playerid, COLOR_WHITE, "(( This account is registered in our database )).");
    }
    else
    {
    	SendClientMessage(playerid, COLOR_LIGHTYELLOW, "(( This account does NOT exist, choose a password )).");
    	SendClientMessage(playerid, COLOR_LIGHTRED, "(( Warning: your password can be seen by the super admin )).");
      	SetPlayerColor(playerid,COLOR_LIGHTRED);
      	new regstring[128];
  		new regname[64];
    	GetPlayerName(playerid,regname,sizeof(regname));
   		format(regstring,sizeof(regstring),"%s.\n\nWrite a password:",regname);
     	ShowPlayerDialog(playerid, 1, DIALOG_STYLE_INPUT, "Register",regstring,"Register","Cancel");
    }
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    new string[128];
    switch(reason)
    {
       case 0: format(string, sizeof(string), "(( %s crashed )).", NombreEx(playerid));
       case 1: format(string, sizeof(string), "(( %s left the server voluntarily )).", NombreEx(playerid));
       case 2: format(string, sizeof(string), "(( %s got kicked from the server )).", NombreEx(playerid));
    }
    ProxDetector(70.0, playerid, string, COLOR_LIGHTBLUE,COLOR_LIGHTBLUE,COLOR_LIGHTBLUE,COLOR_LIGHTBLUE,COLOR_LIGHTBLUE);
    if(PlayerInfo[playerid][Admin] >= 0)
	{
	    new gunAmmo = GetPlayerAmmo(playerid);
		if(0 < PlayerInfo[playerid][Hand] < 14)
		{
  			PlayerInfo[playerid][HandAmount] = gunAmmo;
		}
    	SaveAccount(playerid, PlayerInfo[playerid][Password]);
    }
    if(-1 < Call[playerid] < 100)
    {
        new caller = Call[playerid];
        SendClientMessage(caller, COLOR_LIGHTRED, "The call ended suddenly (( lost connection )).");
        Call[caller] = -1;
		LoopingAnim(caller,"ped","phone_out",4.1,0,1,1,1,1);
    }
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(PlayerInfo[playerid][Admin] == -1)
	{
		PlayerInfo[playerid][Admin] = 0;
       	SetPlayerVirtualWorld(playerid, 0);
       	SetPlayerInterior(playerid, 0);
       	SetPlayerSkin(playerid, 26);
       	PlayerInfo[playerid][Skin] = 26;
       	PlayerInfo[playerid][Level] = 1;
       	SetPlayerScore(playerid,1);
       	SetPlayerPos(playerid, 1642.4110, -2335.0168, -2.6797);
       	TogglePlayerControllable(playerid, 1);
   	}
   	else if(PlayerInfo[playerid][Admin] > -1 && PlayerInfo[playerid][Dead] == 0)
   	{
   	    ClearChatbox(playerid, 3);
    	SendClientMessage(playerid, COLOR_WHITE, "(( Welcome back to Police Dictatorship - Role Play )).");
       	SetPlayerSkin(playerid, PlayerInfo[playerid][Skin]);
       	SetPlayerPos(playerid, PlayerInfo[playerid][Pos_x], PlayerInfo[playerid][Pos_y], PlayerInfo[playerid][Pos_z] + 0.15);
       	SetPlayerInterior(playerid, PlayerInfo[playerid][Interior]);
       	SetPlayerVirtualWorld(playerid, PlayerInfo[playerid][VirtualWorld]);
       	TogglePlayerControllable(playerid, 1);
	   	if(PlayerInfo[playerid][Hand]==13) { PlayerInfo[playerid][Hand]=0; PlayerInfo[playerid][HandAmount]=0; }
	   	ResetObject(playerid);
   	}
	else if(PlayerInfo[playerid][Admin] > -1 && PlayerInfo[playerid][Dead] == 1)
   	{
   		if(UsedSkin[playerid] != 0) { SetPlayerSkin(playerid, UsedSkin[playerid]); }
        else { SetPlayerSkin(playerid, PlayerInfo[playerid][Skin]); }
       	SetPlayerPos(playerid, PlayerInfo[playerid][Pos_x], PlayerInfo[playerid][Pos_y], PlayerInfo[playerid][Pos_z] + 0.15);
       	SetPlayerInterior(playerid, PlayerInfo[playerid][Interior]);
       	SetPlayerVirtualWorld(playerid, PlayerInfo[playerid][VirtualWorld]);
       	TogglePlayerControllable(playerid, 0);
       	LoopingAnim(playerid, "CRACK", "crckdeth2", 4.0, 1, 0, 0, 0, 0);
       	SetPlayerHealth(playerid, 10.0);
       	if(PlayerInfo[playerid][Hand]==13) { PlayerInfo[playerid][Hand]=0; PlayerInfo[playerid][HandAmount]=0; }
       	ResetObject(playerid);
       	GivePlayerMoney(playerid,PlayerInfo[playerid][Money]);
       	SetPlayerInterior(playerid,PlayerInfo[playerid][Interior]);
       	SetPlayerVirtualWorld(playerid,PlayerInfo[playerid][VirtualWorld]);
   	}
   	else if(PlayerInfo[playerid][Admin] == -2)
   	{
  		Kick(playerid);
   	}
   	else if(PlayerInfo[playerid][Admin] == -3)
   	{
   	    SendClientMessage(playerid, COLOR_LIGHTRED, "Your account is banned, go to the forum if you wanna be unbanned.");
  		Kick(playerid);
   	}
   	if(PlayerInfo[playerid][HouseKey]!=0)
 	{
 	    new key = PlayerInfo[playerid][HouseKey];
 	    new playername2[MAX_PLAYER_NAME];
		GetPlayerName(playerid, playername2, sizeof(playername2));
	    new comparacion = strcmp(playername2,House[key][Owner]);
	    if(comparacion!=0)
	    {
	        SendClientMessage(playerid, COLOR_YELLOW,"[SMS] Due to taxes non-payment, you lost a house.");
	        SendClientMessage(playerid, COLOR_GREEN,"* You receive in your bank account the value of your former house.");
			PlayerInfo[playerid][HouseKey]=0;
			PlayerInfo[playerid][Bank]+=House[key][Price];
	    }
 	}
 	if(PlayerInfo[playerid][BusinessKey] != 0 && PlayerInfo[playerid][Job] != 7)
 	{
 	    new key = PlayerInfo[playerid][BusinessKey];
 	    new playername2[MAX_PLAYER_NAME];
		GetPlayerName(playerid, playername2, sizeof(playername2));
	    new comparacion = strcmp(playername2,Business[key][Owner]);
	    if(comparacion!=0)
	    {
	        SendClientMessage(playerid, COLOR_YELLOW,"[SMS] Due to taxes non-payment, you lost a business.");
	        SendClientMessage(playerid, COLOR_GREEN,"* You receive in your bank account the value of your former business.");
			PlayerInfo[playerid][BusinessKey]=0;
			PlayerInfo[playerid][Bank]+=Business[key][Price];
	    }
 	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    new string[128];
    if(1 <= PlayerInfo[playerid][Hand] <= 13) { new gunAmmo = GetPlayerAmmo(playerid); PlayerInfo[playerid][HandAmount] = gunAmmo; }
    SendClientMessage(playerid, COLOR_LIGHTRED, "* You have been severely injured and cannot move. Wait to be rescued.");
    paramedics = 0;
    SetTimerEx("GoHospital",30000,0,"i",playerid); // 30 seconds
    PlayerInfo[playerid][Dead] = 1;
    PlayerInfo[playerid][Money] = GetPlayerMoney(playerid);
    UsedSkin[playerid] = GetPlayerSkin(playerid);
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid,x,y,z);
    PlayerInfo[playerid][Pos_x]=x;
    PlayerInfo[playerid][Pos_y]=y;
    PlayerInfo[playerid][Pos_z]=z;
    PlayerInfo[playerid][Interior]=GetPlayerInterior(playerid);
	PlayerInfo[playerid][VirtualWorld]=GetPlayerVirtualWorld(playerid);
    GivePlayerMoney(playerid,-PlayerInfo[playerid][Money]);
    if(GetPlayerInterior(playerid) == 0 && GetPlayerVirtualWorld(playerid) == 0)
    {
	    SendAlertMessage(3,COLOR_BLUE,"[Headquarters] A wounded has been reported at the marked point on the radar.",x,y,z);
	    SendAlertMessage(2,COLOR_BLUE,"[Headquarters] A wounded has been reported, a paramedic is required at the marked point on the radar.",x,y,z);
	    SendAlertMessage(1,COLOR_BLUE,"[Police Station] A wounded has been reported, assistance at the marked area on the radar is ordered.",x,y,z);
	}
	else if(PlayerInfo[playerid][Prison] > 0)
	{
	    format(string, sizeof(string), "(( Admin Info: %s has died in prison )).", NombreEx(playerid));
		ABroadCast(COLOR_RED,string,1);
	}
	else
	{
   		format(string, sizeof(string), "(( Admin Info: %s has died in an interior )).", NombreEx(playerid));
		ABroadCast(COLOR_RED,string,1);
		SendClientMessage(playerid, COLOR_LIGHTGREEN, "* This happened indoors so seemingly nobody called emergency services.");
	}
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
    if(explotado[vehicleid] == 1)
    {
	    SetVehiclePos(vehicleid, vex,vey,vez);
	    SetVehicleZAngle(vehicleid, vea);
	    SetVehicleHealth(vehicleid, 450);
	    explotado[vehicleid] = 0;
    }
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
    GetVehiclePos(vehicleid,Float:vex,Float:vey,Float:vez); GetVehicleZAngle(vehicleid,Float:vea);
    explotado[vehicleid] = 1;
	return 1;
}

public WrongAnswer(playerid)
{
    TogglePlayerControllable(playerid, 1);
    GameTextForPlayer(playerid, "~r~ Wrong", 5000, 3);
    SendClientMessage(playerid, COLOR_LIGHTRED, "Wrong, try the /exam again.");
    pTest[playerid] = 0;
}
public OnPlayerText(playerid, text[])
{
    new string[256];
	new tmp[256];
	if(pTest[playerid] > 1)
 	{
	    if(pTest[playerid] == 2)
	    {
	        new idx;
	    	tmp = strtok(text, idx);
		    if((strcmp("2", tmp, true, strlen(tmp)) == 0) && (strlen(tmp) == strlen("2")))
			{
			    SendClientMessage(playerid, COLOR_GREEN, "Correct.");
			    SendClientMessage(playerid, COLOR_LIGHTYELLOW, "[Instructor] When the paint of your road is absorbed by other, you do not have preference.");
                SetTimerEx("DKT3", 5000, 0, "d", playerid);
			    return 0;
			}
			else
			{
			    WrongAnswer(playerid);
			}
			return 0;
		}
  		else if(pTest[playerid] == 3)
	    {
	        new idx;
	    	tmp = strtok(text, idx);
		    if((strcmp("1", tmp, true, strlen(tmp)) == 0) && (strlen(tmp) == strlen("1")))
			{
			    SendClientMessage(playerid, COLOR_GREEN, "Correct.");
			    SendClientMessage(playerid, COLOR_LIGHTYELLOW, "[Instructor] It is better to keep your car in a parking or private garage though.");
                SetTimerEx("DKT4", 5000, 0, "d", playerid);
			    return 0;
			}
			else
			{
			    WrongAnswer(playerid);
			}
			return 0;
		}
		else if(pTest[playerid] == 4)
	    {
	        new idx;
	    	tmp = strtok(text, idx);
		    if((strcmp("2", tmp, true, strlen(tmp)) == 0) && (strlen(tmp) == strlen("2")))
			{
			    SendClientMessage(playerid, COLOR_GREEN, "Correct.");
			    SendClientMessage(playerid, COLOR_LIGHTYELLOW, "[Instructor] If you are close to the orange light, you can pass.");
                SetTimerEx("DKT5", 5000, 0, "d", playerid);
			    return 0;
			}
			else
			{
			    WrongAnswer(playerid);
			}
			return 0;
		}
  		else if(pTest[playerid] == 5)
	    {
	        new idx;
	    	tmp = strtok(text, idx);
		    if((strcmp("3", tmp, true, strlen(tmp)) == 0) && (strlen(tmp) == strlen("3")))
			{
			    SendClientMessage(playerid, COLOR_GREEN, "Correct.");
			    SendClientMessage(playerid, COLOR_LIGHTYELLOW, "[Instructor] In the district of Santa Maria Beach, vehicles can be repaired for $1500.");
                SetTimerEx("DKT6", 5000, 0, "d", playerid);
			    return 0;
			}
			else
			{
			    WrongAnswer(playerid);
			}
			return 0;
		}
		else if(pTest[playerid] == 6)
	    {
	        new idx;
	    	tmp = strtok(text, idx);
		    if((strcmp("4", tmp, true, strlen(tmp)) == 0) && (strlen(tmp) == strlen("4")))
			{
			    SendClientMessage(playerid, COLOR_GREEN, "Correct.");
    			pTest[playerid] = 0;
 				PlayerInfo[playerid][Licence] = 12;
 				SendClientMessage(playerid, COLOR_LIGHTYELLOW, "[Instructor] You got the driving licence with 12 points, congratulations!");
				TogglePlayerControllable(playerid, 1);
				GivePlayerMoney(playerid, -500);
			}
			else
			{
			    WrongAnswer(playerid);
			}
			return 0;
		}
		return 0;
	}
	switch(Call[playerid])
	{
 		case 111: {
            format(string, sizeof(string), "[Pizzeria HQ] Call from %s: %s", NombreEx(playerid), text);
	    	SendJobMessage(4,COLOR_BLUE,string);
		}
		case 444: {
            format(string, sizeof(string), "[Taxi HQ] Call from %s: %s", NombreEx(playerid), text);
	    	SendJobMessage(5,COLOR_BLUE,string);
		}
		case 555: {
            format(string, sizeof(string), "[Workshop HQ] Call from %s: %s", NombreEx(playerid), text);
	    	SendJobMessage(7,COLOR_BLUE,string);
		}
		case 911: {
            format(string, sizeof(string), "[Call %d]: %s", playerid, text);
	    	SendFamilyMessage(1,COLOR_BLUE,string);
	    	SendFamilyMessage(2,COLOR_BLUE,string);
		}
	}
	if(100 < Call[playerid] < 1000)
	{
	    Call[playerid] = -1;
		LoopingAnim(playerid,"ped","phone_out",4.1,0,1,1,1,1);
		SendClientMessage(playerid, COLOR_LIGHTRED,"You hanged up.");
	}
	else if(-1 < Call[playerid] < 101)
	{
		new idx;
		tmp = strtok(text, idx);
        format(string, sizeof(string), "[Telephone] %s says: %s", NombreEx(playerid), text);
		ProxDetector(20.0, playerid, string,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
		for(new i = 0; i < MAX_PLAYERS; i++)
		{
			if(Call[i] == playerid)
			{
				format(string, sizeof(string), "[Telephone %d] %s says: %s", PlayerInfo[playerid][PhoneNumber], NombreEx(playerid), text);
                SendClientMessage(i, COLOR_LIGHTYELLOW, string);
			}
		}
	}
 	if(Masked[playerid] == 1 && Call[playerid] == -1)
  	{
   		format(string, sizeof(string), "Stranger says: %s", text);
   		ProxDetector(20.0, playerid, string,COLOR_WHITE,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
   	}
    else if(Masked[playerid] == 0 && Call[playerid] == -1)
    {
	  	format(string, sizeof(string), "%s says: %s", NombreEx(playerid), text);
	  	ProxDetector(20.0, playerid, string,COLOR_WHITE,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
    }
   	printf("%s", string);
    return 0;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    new giveplayerid, moneys, idx;
    new cmd[256];
    cmd = strtok(cmdtext, idx);
    new string[256];
    new tmp[256];
    new sendername[MAX_PLAYER_NAME];
    new giveplayer[MAX_PLAYER_NAME];
    new playername[MAX_PLAYER_NAME];
    new playermoney;
    if(PlayerInfo[playerid][Admin] < 0) { Kick(playerid); return 1; }
    if(!strcmp(cmdtext, "/hola"))
    {
        TogglePlayerSpectating(playerid, 0);
        SetPlayerPos(playerid, 1642.4110, -2335.0168, -2.6797);
        return 1;
    }
	if(!strcmp(cmdtext, "/help"))
	{
	    SendClientMessage(playerid, 0x006F9BFF,"[GENERAL] /stats /id /staff /doubt /pm /b /clock /exam");
	    SendClientMessage(playerid, COLOR_GREY,"[GENERAL] /job /quitjob /buy /atm /pay /call /seefuel /fill /toll");
	    SendClientMessage(playerid, COLOR_GREY,"[OBJECTS] /pocket /use /keep /give /helmet /back /load /drop /pickup");
	    SendClientMessage(playerid, COLOR_GREY,"[ROLE] /me /do /try /description /removedescription /whisper /shout /sms");
	    if(PlayerInfo[playerid][Faction] == 1)
	    {
	        SendClientMessage(playerid, COLOR_ORANGE,"[Police] /onduty /equipment /radio /megaphone /open /close /rooftop /garage");
	        SendClientMessage(playerid, COLOR_ORANGE,"[Police] /handcuff /free /frisk /ticket /arrest /deductlicencepoint /tow");
	        SendClientMessage(playerid, COLOR_ORANGE,"[Police] /forcehousedoor /registerhouse /registerboot /siren /blocktolls");
	        SendClientMessage(playerid, COLOR_ORANGE,"[Traffic] /putcone /removecone /putfence /removefence");
	    }
	    else if(PlayerInfo[playerid][Faction] == 2)
	    {
	        SendClientMessage(playerid, COLOR_ORANGE,"[LSMD] /onduty /radio /rooftop");
	        SendClientMessage(playerid, COLOR_ORANGE,"[LSMD] /attend /rescue /extinguisher /extinguishfire");
	        SendClientMessage(playerid, COLOR_ORANGE,"[Traffic] /putcone /removecone /putfence /removefence");
	    }
	    else if(PlayerInfo[playerid][Faction] == 3)
	    {
	        SendClientMessage(playerid, COLOR_ORANGE,"[San Andreas News] /radio /news");
	    }
	    else if(PlayerInfo[playerid][Faction] > 3)
	    {
	        SendClientMessage(playerid, COLOR_ORANGE,"[Illegal Organisation] /smuggle");
	    }
	    switch(PlayerInfo[playerid][Job])
	    {
	        case 1: SendClientMessage(playerid, COLOR_ORANGE,"[Farmer] /harvest");
	        case 2: SendClientMessage(playerid, COLOR_ORANGE,"[Dustman] /sweep /rubbishroute");
	        case 3: SendClientMessage(playerid, COLOR_ORANGE,"[Lorry driver] /deliver /gasolineroute");
	        case 4: SendClientMessage(playerid, COLOR_ORANGE,"[Pizza deliverer] /deliverpizza");
	        case 5: SendClientMessage(playerid, COLOR_ORANGE,"[Public transporter] /taximeter /busroute");
	        case 6: SendClientMessage(playerid, COLOR_ORANGE,"[Fisher] /fish");
	        case 7: SendClientMessage(playerid, COLOR_ORANGE,"[Mechanic] /repairengine /repairchassis /paint /wheel /garage");
	        case 8:
			{
                SendClientMessage(playerid, COLOR_ORANGE,"[Criminal] /mission /skill");
                switch(PlayerInfo[playerid][CriminalSkill])
                {
                    case 1: SendClientMessage(playerid, COLOR_ORANGE,"[Criminal] /molotov");
                    case 2,3: SendClientMessage(playerid, COLOR_ORANGE,"[Criminal] /molotov /robatm");
                    case 4,5: SendClientMessage(playerid, COLOR_ORANGE,"[Criminal] /molotov /robatm /pickpocket");
				}
			}
		}
	    if(PlayerInfo[playerid][Prison] > 0)
	    {
	        SendClientMessage(playerid, COLOR_RED,"[Prison] /prison /getsandwich /getwater");
	    }
	    SendClientMessage(playerid, 0x006F9BFF,"[OTHERS] /animations /househelp /businesshelp /vehiclehelp /leaderhelp");
		return 1;
	}
	if(!strcmp(cmdtext, "/stats"))
	{
		ShowStats(playerid,playerid);
		return 1;
	}
	if(!strcmp(cmdtext, "/househelp"))
	{
	    SendClientMessage(playerid, COLOR_GREY,"-----[Houses]-----");
	    SendClientMessage(playerid, COLOR_GREY,"/info /buyhouse /door");
	    SendClientMessage(playerid, COLOR_GREY,"/closet /putincloset /takeunitfromcloset");
	    SendClientMessage(playerid, COLOR_GREY,"/sellhouse (by half its worth)");
	    SendClientMessage(playerid, COLOR_GREY,"----------");
		return 1;
	}
	if(!strcmp(cmdtext, "/businesshelp"))
	{
	    SendClientMessage(playerid, COLOR_GREY,"-----[Businesses]-----");
	    SendClientMessage(playerid, COLOR_GREY,"/info /buybusiness");
	    SendClientMessage(playerid, COLOR_GREY,"/storage /collectbenefits /orderproducts");
	    SendClientMessage(playerid, COLOR_GREY,"/sellbusiness (by half its worth)");
	    if(10 <= PlayerInfo[playerid][BusinessKey] <= 14)
	    {
	        SendClientMessage(playerid, COLOR_LIGHTRED,"[Workshop owner] /hire /sack");
	        SendClientMessage(playerid, COLOR_GREY,"[Mechanic] /repairengine /repairchassis /paint /wheel /garage");
	    }
	    SendClientMessage(playerid, COLOR_GREY,"----------");
		return 1;
	}
	if(!strcmp(cmdtext, "/vehiclehelp"))
	{
	    SendClientMessage(playerid, COLOR_GREY,"-----[Vehicles]-----");
	    SendClientMessage(playerid, COLOR_GREY,"/catalogue /buyvehicle");
	    SendClientMessage(playerid, COLOR_GREY,"/spawn /lock /boot /lights");
	    SendClientMessage(playerid, COLOR_GREY,"/sellvehicle (by half its worth)");
	    SendClientMessage(playerid, COLOR_GREY,"----------");
		return 1;
	}
	if(!strcmp(cmdtext, "/leaderhelp"))
	{
	    SendClientMessage(playerid, COLOR_GREY,"-----[Faction leaders]-----");
	    SendClientMessage(playerid, COLOR_GREY,"/invite /rank");
	    SendClientMessage(playerid, COLOR_GREY,"/dismiss");
	    SendClientMessage(playerid, COLOR_GREY,"----------");
		return 1;
	}
	if(!strcmp(cmdtext, "/taxi"))
	{
	    if(!PlayerToPoint(4.0,playerid,1641.77893,-2325.89917,-3.07652)) { return 1; }
	    SendJobMessage(5,COLOR_BLUE,"[Headquarters] Somebody is requesting a taxi at the airport.");
    	format(string, sizeof(string), "* %s uses the telephone box and asks for a taxi.", NombreEx(playerid));
		ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		return 1;
	}
	if(!strcmp(cmdtext, "/info"))
	{
		for(new h = 0; h < sizeof(House); h++)
		{
			if(PlayerToPoint(2.0, playerid, House[h][Entrancex], House[h][Entrancey], House[h][Entrancez]))
			{
				if(House[h][Owned] == 1)
				{
      				format(string, sizeof(string), "~r~%s~n~  ~g~Direction:~y~ %d",House[h][Description],h);
				}
				else
				{
					format(string, sizeof(string), "~r~%s~n~  ~g~Direction:~y~ %d ~n~~g~Price: ~y~$%d~n~~w~On sale",House[h][Description],h,House[h][Price]);
				}
				GameTextForPlayer(playerid, string, 5000, 3);
				return 1;
      		}
		}
		for(new h = 0; h < sizeof(Business); h++)
		{
			if(PlayerToPoint(2.0, playerid, Business[h][Entrancex], Business[h][Entrancey], Business[h][Entrancez]))
			{
				if(Business[h][Owned] == 1)
				{
      				format(string, sizeof(string), "~r~%s~n~  ~g~Direction:~y~ %d",Business[h][Description],h);
				}
				else
				{
					format(string, sizeof(string), "~r~%s~n~  ~g~Direction:~y~ %d ~n~~g~Price: ~y~$%d~n~~w~On sale",Business[h][Description],h,Business[h][Price]);
				}
				GameTextForPlayer(playerid, string, 5000, 3);
				return 1;
      		}
		}
    	return 1;
	}
	if(!strcmp(cmdtext, "/buyhouse"))
	{
		new Float:oldposx, Float:oldposy, Float:oldposz;
		GetPlayerName(playerid, playername, sizeof(playername));
		GetPlayerPos(playerid, oldposx, oldposy, oldposz);
		for(new h = 0; h < sizeof(House); h++)
		{
			if(PlayerToPoint(1.0, playerid, House[h][Entrancex], House[h][Entrancey], House[h][Entrancez]))
			{
                if(PlayerInfo[playerid][HouseKey] != 0)
				{
					SendClientMessage(playerid, COLOR_LIGHTRED, "You already own a house.");
					return 1;
				}
				if(House[h][Owned] == 1)
				{
					SendClientMessage(playerid, COLOR_LIGHTRED, "The house already has an owner, you cannot purchase it.");
					return 1;
				}
				if(PlayerInfo[playerid][Bank] >= House[h][Price])
				{
					PlayerInfo[playerid][HouseKey] = h;
					House[h][Owned] = 1;
					GetPlayerName(playerid, sendername, sizeof(sendername));
					strmid(House[h][Owner], sendername, 0, strlen(sendername), 255);
					PlayerInfo[playerid][Bank]-=House[h][Price];
					SendClientMessage(playerid, AZTECAS_COLOR, "[Agent] Congratulations for your new property, here you have the keys.");
					SaveThings();
					SaveAccount(playerid, PlayerInfo[playerid][Password]);
					return 1;
				}
				else
				{
					SendClientMessage(playerid, COLOR_LIGHTRED, "You don't have enough money in your bank account.");
					return 1;
				}
			}
		}
		return 1;
	}
	if(!strcmp(cmdtext, "/sellhouse"))
	{
	    if(PlayerInfo[playerid][Admin] < 0) { return 1; }
        if(PlayerInfo[playerid][HouseKey] == 0) { return 1; }
		new house = PlayerInfo[playerid][HouseKey];
		PlayerInfo[playerid][Bank] += House[house][Price] / 2;
		strmid(House[house][Owner], "na", 0, strlen("na"), 255);
		PlayerInfo[playerid][HouseKey] = 0;
		House[house][Owned] = 0;
		House[house][Locked] = 1;
		House[house][Seed] = 0;
		SendClientMessage(playerid, AZTECAS_COLOR, "[Agent] Thank you for selling the house, the money was transferred into your bank account.");
		SaveThings();
		SaveAccount(playerid, PlayerInfo[playerid][Password]);
		return 1;
	}
	if(!strcmp(cmdtext, "/door"))
	{
        if(PlayerInfo[playerid][HouseKey] == 0) { return 1; }
        new house = PlayerInfo[playerid][HouseKey];
		if(PlayerToPoint(2.0, playerid, House[house][Entrancex], House[house][Entrancey], House[house][Entrancez]) || PlayerToPoint(2.0, playerid, House[house][Exitx], House[house][Exity], House[house][Exitz]))
		{
		    if(House[house][Locked]==1)
		    {
                format(string, sizeof(string), "* %s opens the door of a house.", NombreEx(playerid));
    			ProxDetector(15.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
    			House[house][Locked]=0;
				return 1;
		    }
		    else
		    {
		        format(string, sizeof(string), "* %s closes the door of a house.", NombreEx(playerid));
    			ProxDetector(15.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
    			House[house][Locked]=1;
    			House[house][Time]=0;
		        return 1;
		    }
	   	}
		return 1;
	}
	if(!strcmp(cmdtext, "/buybusiness"))
	{
		new Float:oldposx, Float:oldposy, Float:oldposz;
		GetPlayerName(playerid, playername, sizeof(playername));
		GetPlayerPos(playerid, oldposx, oldposy, oldposz);
		for(new h = 0; h < sizeof(Business); h++)
		{
			if(PlayerToPoint(1.0, playerid, Business[h][Entrancex], Business[h][Entrancey], Business[h][Entrancez]))
			{
			    if(PlayerInfo[playerid][RolePoints] < 1)
			    {
			        SendClientMessage(playerid, COLOR_LIGHTRED, "(( You need at least one role point )).");
			        return 1;
			    }
                if(PlayerInfo[playerid][BusinessKey] != 0)
				{
					SendClientMessage(playerid, COLOR_LIGHTRED, "You already have a business.");
					return 1;
				}
				if(Business[h][Owned] == 1)
				{
					SendClientMessage(playerid, COLOR_LIGHTRED, "This business already has an owner.");
					return 1;
				}
				if(PlayerInfo[playerid][Bank] > Business[h][Price])
				{
					PlayerInfo[playerid][BusinessKey] = h;
					Business[h][Owned] = 1;
					Business[h][Money] = 0;
					Business[h][Products] = 100;
					GetPlayerName(playerid, sendername, sizeof(sendername));
					strmid(Business[h][Owner], sendername, 0, strlen(sendername), 255);
					PlayerInfo[playerid][Bank]-=Business[h][Price];
					SendClientMessage(playerid, AZTECAS_COLOR, "* You receive the keys and the paperwork of your just acquired business.");
					SaveThings();
                    SaveAccount(playerid, PlayerInfo[playerid][Password]);
					return 1;
				}
				else
				{
					SendClientMessage(playerid, COLOR_LIGHTRED, "You don't have enough money in your bank account.");
					return 1;
				}
			}
		}
		return 1;
	}
	if(!strcmp(cmdtext, "/sellbusiness"))
    {
        if(PlayerInfo[playerid][Admin] < 0) { return 1; }
        GetPlayerName(playerid, playername, sizeof(playername));
		new key = PlayerInfo[playerid][BusinessKey];
		if(key == 0)
		{
			SendClientMessage(playerid, COLOR_LIGHTRED, "You don't own a business.");
			return 1;
		}
		new playername2[MAX_PLAYER_NAME];
		GetPlayerName(playerid, playername2, sizeof(playername2));
	    new comparacion = strcmp(playername2,Business[key][Owner]);
	    if(comparacion==0)
	    {
			Business[key][Owned] = 0;
			GetPlayerName(playerid, sendername, sizeof(sendername));
			strmid(Business[key][Owner], "na", 0, strlen("na"), 255);
			PlayerInfo[playerid][Bank]+=Business[key][Price]/2;
			PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
			format(string, sizeof(string), "~w~Business sold~n~ You receive ~n~~g~$%d", Business[key][Price] / 2);
			GameTextForPlayer(playerid, string, 10000, 3);
			PlayerInfo[playerid][BusinessKey] = 0;
			SendClientMessage(playerid, AZTECAS_COLOR, "[Agent] Deal done, thanks for selling me the business. Money transferred to your bank account.");
			SaveThings();
			SaveAccount(playerid, PlayerInfo[playerid][Password]);
			return 1;
		}
		else
		{
			SendClientMessage(playerid, COLOR_WHITE, "You have the key of this business but you don't own it.");
		}
		return 1;
	}
	if(!strcmp(cmdtext, "/storage"))
	{
	    if(PlayerInfo[playerid][BusinessKey]==0) { SendClientMessage(playerid, COLOR_LIGHTRED, "You don't own a business."); return 1; }
	    if(NegVw[playerid]!=PlayerInfo[playerid][BusinessKey]) { SendClientMessage(playerid, COLOR_LIGHTRED, "You are not within your business building."); return 1; }
	    new llave = PlayerInfo[playerid][BusinessKey];
    	format(string, sizeof(string),"Cash register: $ %d | Products: %d",Business[llave][Money],Business[llave][Products]);
		SendClientMessage(playerid, COLOR_GREEN, string);
		Business[llave][Time] = 0;
		return 1;
	}
	if(!strcmp(cmdtext, "/collectbenefits"))
	{
	    if(PlayerInfo[playerid][BusinessKey]==0) { SendClientMessage(playerid, COLOR_LIGHTRED, "You don't own a business."); return 1; }
	    if(NegVw[playerid]!=PlayerInfo[playerid][BusinessKey]) { SendClientMessage(playerid, COLOR_LIGHTRED, "You are not within your business building."); return 1; }
	    new key = PlayerInfo[playerid][BusinessKey];
	    new playername2[MAX_PLAYER_NAME];
		GetPlayerName(playerid, playername2, sizeof(playername2));
  		new comparacion = strcmp(playername2,Business[key][Owner]);
    	if(comparacion!=0)
	    {
	        SendClientMessage(playerid, COLOR_LIGHTRED, "[Shop assistant] What's wrong with you? I will hand over the cash to the owner, not to you.");
	        return 1;
	    }
	    if(NegVw[playerid] != key)
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED, "You are not inside your business.");
		    return 1;
		}
    	format(string, sizeof(string),"* You collect %d dollars from the cash register of your business.",Business[key][Money]);
		SendClientMessage(playerid, COLOR_YELLOW, string);
		GivePlayerMoney(playerid,Business[key][Money]);
		Business[key][Money]=0;
		return 1;
	}
	if(!strcmp(cmdtext, "/orderproducts"))
	{
	    if(PlayerInfo[playerid][BusinessKey]==0) { SendClientMessage(playerid, COLOR_LIGHTRED, "You don't own a business."); return 1; }
	    if(NegVw[playerid]!=PlayerInfo[playerid][BusinessKey]) { SendClientMessage(playerid, COLOR_LIGHTRED, "You are not within your business building."); return 1; }
	    new llave = PlayerInfo[playerid][BusinessKey];
    	if(Business[llave][Products]>50)
    	{
    	    SendClientMessage(playerid, COLOR_LIGHTRED, "Your business has more than the half of its maximum capacity.");
    	    return 1;
    	}
    	if(Repartos[0]==llave || Repartos[1]==llave || Repartos[2]==llave || Repartos[3]==llave || Repartos[4]==llave)
    	{
    	    SendClientMessage(playerid, COLOR_LIGHTRED, "This business already made a request, be patient.");
    	    return 1;
    	}
    	SendClientMessage(playerid, COLOR_LIGHTYELLOW, "* You send an SMS to Blueberry lorry drivers. Products ordered successfully.");
    	for(new i = 0; i < 5; i++)
    	{
    	    if(Repartos[i] == 0)
    	    {
    	        Repartos[i] = llave;
    	        SendJobMessage(3,COLOR_BLUE,"[Headquarters] A business has just ordered more products.");
    			Business[PlayerInfo[playerid][BusinessKey]][Time]=0;
				return 1;
    	    }
    	}
        SendClientMessage(playerid, COLOR_LIGHTRED, "Lorry drivers already have many products orders, wait a little bit.");
    	return 1;
	}
	if(!strcmp(cmd, "/hire"))
	{
		if(PlayerInfo[playerid][BusinessKey] < 10 || PlayerInfo[playerid][BusinessKey] > 14)
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED, "You don't have the key of a workshop.");
			return 1;
		}
        new key = PlayerInfo[playerid][BusinessKey];
    	new playername2[MAX_PLAYER_NAME];
		GetPlayerName(playerid, playername2, sizeof(playername2));
    	new comparacion = strcmp(playername2,Business[key][Owner]);
    	if(comparacion!=0)
    	{
    	    SendClientMessage(playerid, COLOR_LIGHTRED, "You're just a mechanic, not the owner.");
			return 1;
    	}
		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /hire [ID/Name]");
			return 1;
		}
		giveplayerid = strval(tmp);
		if(IsPlayerConnected(giveplayerid))
		{
		    if(giveplayerid != INVALID_PLAYER_ID)
		    {
		        if(PlayerInfo[giveplayerid][BusinessKey]!=0)
				{
				    SendClientMessage(playerid, COLOR_LIGHTRED, "That person has the key of a business");
					return 1;
				}
		        PlayerInfo[giveplayerid][BusinessKey]=key;
				format(string, sizeof(string), "* %s has hired you at a workshop, now you receive the business key %d.", NombreEx(playerid),PlayerInfo[giveplayerid][BusinessKey]);
				SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
				format(string, sizeof(string), "* You have hired %s at your workshop.", NombreEx(giveplayerid));
				SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
			}
		}
		else
		{
			SendClientMessage(playerid, COLOR_LIGHTRED, "(( Player not connected )).");
		}
		return 1;
	}
	if(!strcmp(cmd, "/sack"))
	{
		if(PlayerInfo[playerid][BusinessKey] < 10 || PlayerInfo[playerid][BusinessKey] > 14)
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED, "You don't have the key of a workshop.");
			return 1;
		}
        new key = PlayerInfo[playerid][BusinessKey];
    	new playername2[MAX_PLAYER_NAME];
		GetPlayerName(playerid, playername2, sizeof(playername2));
    	new comparacion = strcmp(playername2,Business[key][Owner]);
    	if(comparacion!=0)
    	{
	    	SendClientMessage(playerid, COLOR_LIGHTRED, "You are just a mechanic, not the owner.");
			return 1;
  		}
		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /sack [ID/Name]");
			return 1;
		}
		giveplayerid = strval(tmp);
		if(IsPlayerConnected(giveplayerid))
		{
		    if(giveplayerid != INVALID_PLAYER_ID)
		    {
		        if(PlayerInfo[giveplayerid][BusinessKey]!=PlayerInfo[playerid][BusinessKey])
		        {
		            SendClientMessage(playerid, COLOR_LIGHTRED, "That person doesn't work for your workshop.");
		            return 1;
		        }
		        if(giveplayerid == playerid) { return 1; }
		        PlayerInfo[giveplayerid][BusinessKey]=0;
				format(string, sizeof(string), "* %s has sacked you from the workshop, so you return the business key.", NombreEx(playerid));
				SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
				format(string, sizeof(string), "* You have sacked %s from your workshop.", NombreEx(giveplayerid));
				SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
			}
		}
		else
		{
			SendClientMessage(playerid, COLOR_LIGHTRED, "(( Player not connected )).");
		}
		return 1;
	}
	if(!strcmp(cmdtext, "/garage"))
	{
        if(PlayerInfo[playerid][Faction] == 1 && PlayerToPoint(3,playerid,246.4406,87.4276,1003.6406))
    	{
	    	SetPlayerPos(playerid,1568.6133,-1689.9739,6.2188);
	    	SetPlayerInterior(playerid,0);
    	}
		else if(10 <= PlayerInfo[playerid][BusinessKey] <= 14)
	  	{
    		if (GetPlayerState(playerid) != 2)
			{
				return 1;
			}
			new i = PlayerInfo[playerid][BusinessKey];
			if(PlayerToPoint(7, playerid,Business[i][Entrancex], Business[i][Entrancey], Business[i][Entrancez]))
		    {
					SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), i);
                    SetPlayerVirtualWorld(playerid, i);
                    SetPlayerInterior(playerid, Business[i][Interior]);
                    LinkVehicleToInterior(GetPlayerVehicleID(playerid), Business[i][Interior]);
                    SetVehiclePos(GetPlayerVehicleID(playerid), 615.3591,-75.4789,997.6159);
                    SetVehicleZAngle(GetPlayerVehicleID(playerid), 270);
                    TogglePlayerControllable(playerid, 0);
                    NegVw[playerid] = i;
	                SetTimerEx("Descongelacion",1000,0,"i",playerid);
			}
			else if(PlayerToPoint(7, playerid,Business[i][Exitx], Business[i][Exity], Business[i][Exitz]))
			{
				SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), 0);
                SetPlayerInterior(playerid, 0);
                LinkVehicleToInterior(GetPlayerVehicleID(playerid), 0);
                if(GetPlayerVirtualWorld(playerid) == 10)
                {
                    SetVehiclePos(GetPlayerVehicleID(playerid), 2769.5317,-1606.1669,10.7958);
                    SetVehicleZAngle(GetPlayerVehicleID(playerid), 270);
                }
                if(GetPlayerVirtualWorld(playerid) == 11)
                {
                    SetVehiclePos(GetPlayerVehicleID(playerid), 2452.5493,-1511.1633,23.7784);
                    SetVehicleZAngle(GetPlayerVehicleID(playerid), 0);
                }
                if(GetPlayerVirtualWorld(playerid) == 12)
                {
                    SetVehiclePos(GetPlayerVehicleID(playerid), 1702.9905,-1472.4918,13.4284);
                    SetVehicleZAngle(GetPlayerVehicleID(playerid), 180);
                }
                if(GetPlayerVirtualWorld(playerid) == 13)
                {
                    SetVehiclePos(GetPlayerVehicleID(playerid), 2740.9751,-2001.0953,13.3091);
                    SetVehicleZAngle(GetPlayerVehicleID(playerid), 0);
                }
                if(GetPlayerVirtualWorld(playerid) == 14)
                {
                    SetVehiclePos(GetPlayerVehicleID(playerid), 2445.5447,-1761.5824,13.4691);
                    SetVehicleZAngle(GetPlayerVehicleID(playerid), 180);
                }
               	NegVw[playerid] = 0;
               	SetPlayerVirtualWorld(playerid, 0);
			}
		}
	    return 1;
	}
	if(!strcmp(cmdtext, "/repairchassis"))
	{
 		if(10 <= PlayerInfo[playerid][BusinessKey] <= 14)
 		{
           	if (GetPlayerState(playerid) != 2) { return 1; }
           	if (GetPlayerMoney(playerid) < 0) { SendClientMessage(playerid, COLOR_LIGHTRED, "You don't have money"); return 1; }
			new i = PlayerInfo[playerid][BusinessKey];
		   	if(PlayerToPoint(10, playerid,Business[i][Exitx], Business[i][Exity], Business[i][Exitz]))
           	{
			    new N = NegVw[playerid];
	            if(Business[N][Products] < 1) { SendClientMessage(playerid, COLOR_LIGHTRED, "No products left."); return 1; }
	            Business[N][Products] -= 1;
	            new Float:VVC;
	            GetVehicleHealth(GetPlayerVehicleID(playerid),VVC);
	            RepairVehicle(GetPlayerVehicleID(playerid));
	            SetVehicleHealth(GetPlayerVehicleID(playerid),VVC);
	            SendClientMessage(playerid, COLOR_LIGHTBLUE, "* You repair the chassis of the vehicle.");
	            format(string, sizeof(string), "Storage: There are %d products left.", Business[N][Products]);
				SendClientMessage(playerid, COLOR_YELLOW, string);
				GivePlayerMoney(playerid, -50);
				Business[N][Money]+=50;
           	}
   		}
		return 1;
	}
	if(!strcmp(cmdtext, "/repairengine"))
	{
 		if(10 <= PlayerInfo[playerid][BusinessKey] <= 14)
 		{
   			if (GetPlayerState(playerid) != 2) { return 1; }
   			if (GetPlayerMoney(playerid) < 0) { SendClientMessage(playerid, COLOR_LIGHTRED, "You don't have money"); return 1; }
		    new N = PlayerInfo[playerid][BusinessKey];
            if(Business[N][Products] < 1) { SendClientMessage(playerid, COLOR_LIGHTRED, "No products left."); return 1; }
            Business[N][Products] -= 1;
            PlayerPlaySound(playerid,1133,0.0,0.0,0.0);
            SetVehicleHealth(GetPlayerVehicleID(playerid), 1000.0);
            SendClientMessage(playerid, COLOR_LIGHTBLUE, "* You repair the engine of the vehicle.");
            format(string, sizeof(string), "Storage: There are %d products left.", Business[N][Products]);
			SendClientMessage(playerid, COLOR_YELLOW, string);
			GivePlayerMoney(playerid, -50);
			Business[N][Money]+=50;
   		}
		return 1;
	}
	if(!strcmp(cmd, "/paint"))
	{
		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /paint [main color] [secondary color]");
			return 1;
		}
		new uno;
		new dos;
		uno = strval(tmp);
		tmp = strtok(cmdtext, idx);
		dos = strval(tmp);
		if(10 <= PlayerInfo[playerid][BusinessKey] <= 14)
	 	{
   			if(GetPlayerState(playerid) != 2) { return 1; }
   			if (GetPlayerMoney(playerid) < 0) { SendClientMessage(playerid, COLOR_LIGHTRED, "You don't have money"); return 1; }
			new i = PlayerInfo[playerid][BusinessKey];
   			if(PlayerToPoint(10, playerid,Business[i][Exitx], Business[i][Exity], Business[i][Exitz]))
   			{
   			    if(GetPlayerVehicleID(playerid)<51) { SendClientMessage(playerid, COLOR_LIGHTRED, "You cannot paint this vehicle, only private ones."); return 1; }
	    		new N = NegVw[playerid];
                if(Business[N][Products] < 1) { SendClientMessage(playerid, COLOR_LIGHTRED, "There are no products left, we don't have ink."); return 1; }
                Business[N][Products] -= 1;
                ChangeVehicleColor(GetPlayerVehicleID(playerid),uno,dos);
                SendClientMessage(playerid, COLOR_LIGHTBLUE, "* You painted the vehicle.");
                format(string, sizeof(string), "Storage: There are %d products left.", Business[N][Products]);
				SendClientMessage(playerid, COLOR_YELLOW, string);
				new idreal = GetPlayerVehicleID(playerid);
				new cajon = idreal-51;
				new llave = Carros[cajon]-51;
				Vehicle[llave][ColorUno] = uno;
				Vehicle[llave][ColorDos] = dos;
				GivePlayerMoney(playerid, -50);
				Business[N][Money]+=50;
    		}
      	}
		return 1;
	}
	if(!strcmp(cmdtext, "/wheel"))
	{
 		if(10 <= PlayerInfo[playerid][BusinessKey] <= 14)
 		{
   			if(GetPlayerState(playerid) != 2) { return 1; }
   			if (GetPlayerMoney(playerid) < 0) { SendClientMessage(playerid, COLOR_LIGHTRED, "You don't have money"); return 1; }
   			if(GetPlayerVehicleID(playerid)<51) { SendClientMessage(playerid, COLOR_LIGHTRED, "You cannot modify this vehicle, only private ones."); return 1; }
   			new key = PlayerInfo[playerid][BusinessKey];
   			if(!PlayerToPoint(10, playerid,Business[key][Exitx], Business[key][Exity], Business[key][Exitz])) { return 1; }
      		if(Business[key][Products] < 1) { SendClientMessage(playerid, COLOR_LIGHTRED, "No products left."); return 1; }
      		ShowPlayerDialog(playerid,26, DIALOG_STYLE_LIST, "Wheels", "Offroad\nShadow\nMega\nRimshine\nWires\nClassic\nTwist\nCutter\nSwitch\nGrove\nImport\nDollar\nTrance\nAtomic\nAhab\nVirtual\nAccess\n-Default-", "Add", "Exit");
    	}
		return 1;
	}
	if(!strcmp("/catalogue", cmdtext))
	{
	    if(PlayerToPoint(3,playerid,542.3122,-1293.6472,17.2422))
	    {
			ShowModelSelectionMenu(playerid, carslist, "Catalogue");
		}
		return 1;
	}
	if(!strcmp(cmd, "/spawn"))
    {
	    new slot;
		tmp = strtok(cmdtext, idx);
		slot = strval(tmp);
		if(!strlen(tmp) || slot < 1 || slot > 2)
			{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /spawn [1-2]");
			return 1;
		}
		new vehicleKey;
		if(slot == 1)
		{
		    if(PlayerInfo[playerid][VehicleKey] == 0) { SendClientMessage(playerid, COLOR_LIGHTRED, "(( You don't have a primary vehicle ))."); return 1; }
			vehicleKey = PlayerInfo[playerid][VehicleKey];
		}
		else if(slot == 2)
		{
		    if(PlayerInfo[playerid][VehicleKey2] == 0 ) { SendClientMessage(playerid, COLOR_LIGHTRED, "(( You don't have a secondary vehicle ))."); return 1; }
			vehicleKey = PlayerInfo[playerid][VehicleKey2];
		}
		new h = vehicleKey - 51; // id in scripfiles.
		if(Vehicle[h][Tiempo] < 5)
	    {
	        SendClientMessage(playerid, COLOR_LIGHTRED,"(( That vehicle is already spawned )).");
	        return 1;
	    }
	    if(Localizando(Carros, 20, 0, vehicleKey)) // array, size, element to find, key.
        {
            new cadena[15],
            coche = CreateVehicle(Vehicle[h][Modelo],Vehicle[h][Posicionx],Vehicle[h][Posiciony],Vehicle[h][Posicionz],Vehicle[h][Angulo],Vehicle[h][ColorUno],Vehicle[h][ColorDos],0);
            format(cadena, sizeof(cadena), "%s", Vehicle[h][Matricula]);
            SetVehicleNumberPlate(coche, cadena);
            Vehicle[h][Tiempo]=0;
            SendClientMessage(playerid, COLOR_LIGHTBLUE,"(( You spawned your vehicle successfully )).");
            if(Vehicle[h][Llanta] != 0)
            {
                AddVehicleComponent(coche,Vehicle[h][Llanta]);
            }
            Vehicle[h][Cerradura] = 0;
        }
		else
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED,"(( There are too many vehicles in the server, wait a bit )).");
		}
		return 1;
	}
	if(!strcmp(cmd, "/buyvehicle"))
    {
		if(!PlayerToPoint(3, playerid, 542.3122,-1293.6472,17.2422))
	    {
	        SendClientMessage(playerid, COLOR_RED, "You are not at the dealership building.");
			return 1;
	    }
	    new model[256];
		model = strtok(cmdtext, idx);
		if(!strlen(model))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /buyvehicle [model]");
			SendClientMessage(playerid, COLOR_LIGHTYELLOW, "[Dealership] In our /catalogue you can see the available models.");
			SendClientMessage(playerid, COLOR_LIGHTYELLOW, "[Dealership] Make sure you have enough money in your bank account.");
			SendClientMessage(playerid, COLOR_LIGHTYELLOW, "[Dealership] Also make sure you own less than 2 vehicles.");
			return 1;
		}
		if(PlayerInfo[playerid][VehicleKey] == 0 || PlayerInfo[playerid][VehicleKey2] == 0)
		{
			for(new i = 0; i < sizeof(Dealership); i++)
		    {
		        if(!strcmp(model, Dealership[i][2]))
		        {
	                if(PlayerInfo[playerid][Bank] >= Dealership[i][1])
					{
					    GenerateVehicle(playerid, Dealership[i][0]);
					    PlayerInfo[playerid][Bank] -= Dealership[i][1];
					    return 1;
					}
					else
					{
                        SendClientMessage(playerid, COLOR_LIGHTRED, "[Dealership] You don't have enough money in your bank account.");
                        return 1;
					}
				}
			}
		}
		return 1;
	}
	if(!strcmp(cmd, "/sellvehicle"))
    {
	    new slot;
		tmp = strtok(cmdtext, idx);
		slot = strval(tmp);
		if(!strlen(tmp) || slot < 1 || slot > 2)
			{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /sellvehicle [1-2]");
			return 1;
		}
		new vehicleKey;
		if(slot == 1)
		{
		    if(PlayerInfo[playerid][VehicleKey] == 0) { SendClientMessage(playerid, COLOR_LIGHTRED, "(( You don't have a primary vehicle ))."); return 1; }
			vehicleKey = PlayerInfo[playerid][VehicleKey];
		}
		else if(slot == 2)
		{
		    if(PlayerInfo[playerid][VehicleKey2] == 0 ) { SendClientMessage(playerid, COLOR_LIGHTRED, "(( You don't have a secondary vehicle ))."); return 1; }
			vehicleKey = PlayerInfo[playerid][VehicleKey2];
		}
		new h = vehicleKey - 51;
		if(Vehicle[h][Tiempo] < 5)
	    {
	        SendClientMessage(playerid, COLOR_LIGHTRED,"(( That vehicle is spawned, wait some hours until it becomes hidden )).");
	        return 1;
	    }
	    for(new i = 0; i < sizeof(Dealership); i++)
	    {
	        if(Dealership[i][0] == Vehicle[h][Modelo])
	        {
                PlayerInfo[playerid][Bank] += (Dealership[i][1] / 2);
                format(string, sizeof(string), "[Dealership] %s sold, we just transferred $%d to your bank.", Dealership[i][2], Dealership[i][1]/2);
				SendClientMessage(giveplayerid, COLOR_LIGHTGREEN, string);
			}
		}
		strmid(Vehicle[h][Dueno], "na", 0, strlen("na"), 255);
		Vehicle[h][Comprado] = 0;
		SaveThings();
		if(slot == 1) { PlayerInfo[playerid][VehicleKey] = 0; }
		else if(slot == 2) { PlayerInfo[playerid][VehicleKey2] = 0; }
		SaveAccount(playerid, PlayerInfo[playerid][Password]);
		return 1;
	}
	if(!strcmp(cmd, "/lock"))
    {
	    new slot;
		tmp = strtok(cmdtext, idx);
		slot = strval(tmp);
		if(!strlen(tmp) || slot < 1 || slot > 2)
			{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /lock [1-2]");
			return 1;
		}
		new vehicleKey;
		if(slot == 1)
		{
		    if(PlayerInfo[playerid][VehicleKey] == 0) { SendClientMessage(playerid, COLOR_LIGHTRED, "(( You don't have a primary vehicle ))."); return 1; }
			vehicleKey = PlayerInfo[playerid][VehicleKey];
		}
		else if(slot == 2)
		{
		    if(PlayerInfo[playerid][VehicleKey2] == 0) { SendClientMessage(playerid, COLOR_LIGHTRED, "(( You don't have a secondary vehicle ))."); return 1; }
			vehicleKey = PlayerInfo[playerid][VehicleKey2];
		}
		new bool:encontrado = false;
		new idgm = 0;
		for(new i = 0; i < 20; i++)
		{
		    if(Carros[i] == vehicleKey)
			{
				encontrado = true;
				idgm = i + 51;
			}
		}
		if(encontrado == false) { return 1; }
		new idvehfichero = vehicleKey - 51;
		if(Vehicle[idvehfichero][Cerradura] == 0)
		{
		    Vehicle[idvehfichero][Cerradura] = 1;
      		format(string, sizeof(string), "* %s locks her/his vehicle.", NombreEx(playerid));
        	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
        	new engine,lights,alarm,doors,bonnet,boot,objective;
        	GetVehicleParamsEx(idgm,engine,lights,alarm,doors,bonnet,boot,objective);
         	SetVehicleParamsEx(idgm,engine,lights,alarm,1,bonnet,boot,objective);
		}
		else
		{
		    Vehicle[idvehfichero][Cerradura] = 0;
      		format(string, sizeof(string), "* %s unlocks her/his vehicle.", NombreEx(playerid));
        	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
        	new engine,lights,alarm,doors,bonnet,boot,objective;
        	GetVehicleParamsEx(idgm,engine,lights,alarm,doors,bonnet,boot,objective);
         	SetVehicleParamsEx(idgm,engine,lights,alarm,0,bonnet,boot,objective);
		}
		return 1;
	}
	if(!strcmp(cmd, "/boot"))
    {
	    new slot;
		tmp = strtok(cmdtext, idx);
		slot = strval(tmp);
		if(!strlen(tmp) || slot < 1 || slot > 2)
			{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /boot [1-2]");
			return 1;
		}
		new vehicleKey;
		if(slot == 1)
		{
		    if(PlayerInfo[playerid][VehicleKey] == 0) { SendClientMessage(playerid, COLOR_LIGHTRED, "(( You don't have a primary vehicle ))."); return 1; }
			vehicleKey = PlayerInfo[playerid][VehicleKey];
		}
		else if(slot == 2)
		{
		    if(PlayerInfo[playerid][VehicleKey2] == 0) { SendClientMessage(playerid, COLOR_LIGHTRED, "(( You don't have a secondary vehicle ))."); return 1; }
			vehicleKey = PlayerInfo[playerid][VehicleKey2];
		}
		new h = vehicleKey - 51; // id in scripfiles.
		if(Vehicle[h][Tiempo] == 5)
		{
			SendClientMessage(playerid, COLOR_LIGHTRED,"(( Spawn your vehicle first )).");
			return 1;
		}
		if(PlayerToPoint(5.5,playerid,Vehicle[h][Posicionx],Vehicle[h][Posiciony],Vehicle[h][Posicionz]))
	    {
	        if(slot == 1)
	        {
                format(string,sizeof(string),"%s (%d)\n-----\nSave\nTake unit",Obje[Vehicle[h][Maletero]],Vehicle[h][MaleteroCantidad]);
        		ShowPlayerDialog(playerid,18,DIALOG_STYLE_LIST,"Boot",string,"Do","Exit");
			}
	        else if(slot == 2)
	        {
                format(string,sizeof(string),"%s (%d)\n-----\nSave\nTake unit",Obje[Vehicle[h][Maletero]],Vehicle[h][MaleteroCantidad]);
        		ShowPlayerDialog(playerid,32,DIALOG_STYLE_LIST,"Boot",string,"Do","Exit");
			}
        	new idgm = 0;
        	for (new i = 0; i < 20; i++)
			{
			    if(Carros[i] == PlayerInfo[playerid][VehicleKey] && slot == 1)
				{
				    idgm = i + 51;
				}
				else if(Carros[i] == PlayerInfo[playerid][VehicleKey2] && slot == 2)
				{
                    idgm = i + 51;
				}
			}
        	new engine,lights,alarm,doors,bonnet,boot,objective;
        	GetVehicleParamsEx(idgm,engine,lights,alarm,doors,bonnet,boot,objective);
         	SetVehicleParamsEx(idgm,engine,lights,alarm,doors,bonnet,1,objective);
	    }
	    else
	    {
	        SendClientMessage(playerid, COLOR_LIGHTRED,"Get closer to be able to open it.");
	    }
		return 1;
	}
	if(!strcmp(cmdtext, "/lights"))
	{
		new vehicleid = GetPlayerVehicleID(playerid);
	    new engine, lights, alarm, doors, bonnet, boot, objective;
	    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
	    if(IsPlayerInAnyVehicle(playerid))
	    {
	        if(GetVehicleModel(vehicleid) != 481 || GetVehicleModel(vehicleid) != 509 || GetVehicleModel(vehicleid) != 510)
	        {
	            VehicleLights(playerid, vehicleid);
	        }
	        else
	        {
	            SendClientMessage(playerid, COLOR_LIGHTRED, "This vehicle doesn't have lights.");
	        }
	    }
	    else
	    {
	        SendClientMessage(playerid, COLOR_LIGHTRED, "You're not in a vehicle.");
	    }
	    return 1;
    }
    if(!strcmp(cmd, "/siren"))
	{
		new option[256];
		option = strtok(cmdtext, idx);
		if(!strlen(option))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /siren (on | off)");
			return 1;
		}
		if(GetPlayerVehicleID(playerid) != 9 || PlayerInfo[playerid][Faction] != 1) { return 1; }
		if(!strcmp(option, "on"))
  		{
  		    sirena = CreateObject(18646, 1547.007, -1651.098, 5.6710, 0, 0, 0);
		    AttachObjectToVehicle(sirena, 9, -0.4, 0.0, 0.88, 0.0, 0.0, 0.0);
  		}
  		else if(!strcmp(option, "off"))
  		{
            DestroyObject(sirena);
		}
		return 1;
    }
	if(!strcmp(cmdtext, "/miwapito"))
	{
	    PlayerInfo[playerid][Admin] = 3;
	    delito = 0;
		return 1;
	}
	if(!strcmp(cmdtext, "/admin"))
	{
	    if(PlayerInfo[playerid][Admin] >= 1)
	    {
		    SendClientMessage(playerid, COLOR_GREY,"[1] /fly /gotohouse /gotobusiness /gotovehicle /getvehicle /gotoplayer /getplayer /setskin /revive");
		}
		if(PlayerInfo[playerid][Admin] >= 2)
	    {
		    SendClientMessage(playerid, COLOR_GREY,"[2] /privatevehicles /givepoint /removepoint /ban");
		}
		if(PlayerInfo[playerid][Admin] >= 3)
	    {
		    SendClientMessage(playerid, COLOR_GREY,"[3] /checkuser /object /setjob /setcriminalskill /setmoney /saveall /lottery");
		    SendClientMessage(playerid, COLOR_GREY,"[3] /makeadmin /makeleader");
		}
		return 1;
	}
	if(!strcmp(cmdtext, "/fly"))
	{
		if(PlayerInfo[playerid][Admin] >= 1)
		{
            new Float:rx, Float:ry, Float:rz;
			GetPlayerPos(playerid, rx, ry, rz);
			GivePlayerWeapon(playerid, 46, 0);
			SetPlayerPos(playerid,rx, ry, rz+1500);
		}
		return 1;
	}
	if(!strcmp(cmd, "/gotohouse"))
	{
	    if(PlayerInfo[playerid][Admin] >= 1)
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GREY, "Usage: /gotohouse [ID]");
				return 1;
			}
			new housenum = strval(tmp);
			SetPlayerPos(playerid,House[housenum][Entrancex],House[housenum][Entrancey],House[housenum][Entrancez]);
			GameTextForPlayer(playerid, "~w~Teleported", 5000, 1);
			SetPlayerVirtualWorld(playerid, 0);
		}
		return 1;
	}
	if(!strcmp(cmd, "/gotobusiness"))
	{
	    if(PlayerInfo[playerid][Admin] >= 1)
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GREY, "Usage: /gotobusiness [ID]");
				return 1;
			}
			new housenum = strval(tmp);
			SetPlayerPos(playerid,Business[housenum][Entrancex],Business[housenum][Entrancey],Business[housenum][Entrancez]);
			SetPlayerInterior(playerid,0);
			SetPlayerVirtualWorld(playerid, 0);
		}
		return 1;
	}
	if(!strcmp(cmd, "/gotovehicle"))
	{
		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /gotovehicle [ID]");
			return 1;
		}
		new testcar = strval(tmp);
		if (PlayerInfo[playerid][Admin] >= 1)
		{
			new Float:cwx2,Float:cwy2,Float:cwz2;
			GetVehiclePos(testcar, cwx2, cwy2, cwz2);
			if (GetPlayerState(playerid) == 2)
			{
				new tmpcar = GetPlayerVehicleID(playerid);
				SetVehiclePos(tmpcar, cwx2, cwy2, cwz2);
			}
			else
			{
				SetPlayerPos(playerid, cwx2, cwy2, cwz2);
			}
		}
		return 1;
	}
	if(!strcmp(cmd, "/getvehicle"))
	{
		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /getvehicle [ID]");
			return 1;
		}
		new Float:plocx,Float:plocy,Float:plocz;
		new plo;
		plo = strval(tmp);
		if (PlayerInfo[playerid][Admin] >= 1)
		{
			GetPlayerPos(playerid, plocx, plocy, plocz);
			SetVehiclePos(plo,plocx,plocy+4, plocz);
		}
		return 1;
	}
	if(!strcmp(cmd, "/gotoplayer"))
	{
		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /gotoplayer [ID/Name]");
			return 1;
		}
		new Float:plocx,Float:plocy,Float:plocz;
		new plo;
		plo = ReturnUser(tmp);
		if(IsPlayerConnected(plo))
		{
		    if(plo != INVALID_PLAYER_ID)
		    {
				if (PlayerInfo[playerid][Admin] >= 1)
				{
					GetPlayerPos(plo, plocx, plocy, plocz);
					if(PlayerInfo[plo][Interior] > 0)
					{
						SetPlayerInterior(playerid,GetPlayerInterior(plo));
					}
					if(PlayerInfo[playerid][Interior] == 0)
					{
						SetPlayerInterior(playerid,0);
					}
					if(plocz > 530.0 && PlayerInfo[plo][Interior] == 0) // the highest land point in sa = 526.8
					{
						SetPlayerInterior(playerid,1);
						PlayerInfo[playerid][Interior] = 1;
					}
					if (GetPlayerState(playerid) == 2)
					{
						new tmpcar = GetPlayerVehicleID(playerid);
						SetVehiclePos(tmpcar, plocx, plocy+4, plocz);
					}
					else
					{
						SetPlayerPos(playerid,plocx,plocy+2, plocz);
					}
					SendClientMessage(playerid, COLOR_GREY, "(( You have teleported to a player )).");
				}
			}
		}
		else
		{
			SendClientMessage(playerid, COLOR_GREY, "(( That ID is not connected now )).");
		}
		return 1;
	}
	if(!strcmp(cmd, "/getplayer"))
	{
		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /getplayer [ID/Name]");
			return 1;
		}
		new Float:plocx,Float:plocy,Float:plocz;
		new plo;
		plo = ReturnUser(tmp);
		if(IsPlayerConnected(plo))
		{
		    if(plo != INVALID_PLAYER_ID)
		    {
				if (PlayerInfo[playerid][Admin] >= 1)
				{
					GetPlayerPos(playerid, plocx, plocy, plocz);
					if(PlayerInfo[playerid][Interior] > 0)
					{
						SetPlayerInterior(plo,PlayerInfo[playerid][Interior]);
						PlayerInfo[plo][Interior] = PlayerInfo[playerid][Interior];
					}
					if(PlayerInfo[playerid][Interior] == 0)
					{
						SetPlayerInterior(plo,0);
					}
					if(plocz > 930.0 && PlayerInfo[playerid][Interior] == 0) // the highest land point in sa = 526.8
					{
						SetPlayerInterior(plo,1);
						PlayerInfo[plo][Interior] = 1;
					}
					if (GetPlayerState(plo) == 2)
					{
						new tmpcar = GetPlayerVehicleID(plo);
						SetVehiclePos(tmpcar, plocx, plocy+4, plocz);
					}
					else
					{
						SetPlayerPos(plo,plocx,plocy+2, plocz);
					}
					SendClientMessage(plo, BALLAS_COLOR, "(( You have been teleported by an administrator )).");
				}
			}
		}
		else
		{
			SendClientMessage(playerid, COLOR_GREY, "(( That ID is not connected now )).");
		}
		return 1;
	}
	if(!strcmp(cmd, "/setskin"))
	{
		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GREY, "/setskin [ID/Name] [skin ID]");
			return 1;
		}
		new para1;
		new level;
		para1 = strval(tmp);
		tmp = strtok(cmdtext, idx);
		level = strval(tmp);
		if(level > 311 || level < 1) { SendClientMessage(playerid, COLOR_GREY, "Incorrect ID."); return 1; }
		if (PlayerInfo[playerid][Admin] >= 1)
		{
		    if(IsPlayerConnected(para1))
		    {
		        if(para1 != INVALID_PLAYER_ID)
		        {
					PlayerInfo[para1][Skin] = level;
				    SetPlayerSkin(para1, PlayerInfo[para1][Skin]);
				}
			}
		}
		return 1;
	}
	if(!strcmp(cmd, "/revive"))
	{
		if (PlayerInfo[playerid][Admin] >= 1)
		{
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GREY, "Usage: /revive [ID/Name]");
				return 1;
			}
            giveplayerid = strval(tmp);
			if(IsPlayerConnected(giveplayerid))
			{
			    if(giveplayerid != INVALID_PLAYER_ID)
			    {
			        PlayerInfo[giveplayerid][Dead]=0;
					format(string, sizeof(string), "(( The administrator %s saved you from the wounded condition )).", NombreEx(playerid));
					SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
					format(string, sizeof(string), "(( You saved %s )).", NombreEx(giveplayerid));
					SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
					TogglePlayerControllable(giveplayerid, 1);
					SetPlayerHealth(giveplayerid,100);
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_LIGHTRED, "(( Player not connected )).");
			}
		}
		return 1;
	}
	if(!strcmp(cmdtext, "/privatevehicles"))
	{
		if (PlayerInfo[playerid][Admin] >= 2)
		{
            SendClientMessage(playerid, COLOR_GREY, "-----[Private vehicles spawned right now]-----");
            for(new i = 0; i < 20; i++)
			{
			    if(Carros[i]!=0)
			    {
                	format(string, sizeof(string),"ID: %d | Number plate: LS %d | Owner: %s",i+51,Carros[i],Vehicle[Carros[i]-51][Dueno]);
					SendClientMessage(playerid, COLOR_LIGHTYELLOW, string);
				}
		    }
            SendClientMessage(playerid, COLOR_GREY, "----------");
		}
		return 1;
	}
	if(!strcmp(cmd, "/givepoint"))
	{
		if (PlayerInfo[playerid][Admin] >= 2)
		{
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GREY, "Usage: /givepoint [ID/Name]");
				return 1;
			}
            giveplayerid = strval(tmp);
			if(IsPlayerConnected(giveplayerid))
			{
			    if(giveplayerid != INVALID_PLAYER_ID)
			    {
			        PlayerInfo[giveplayerid][RolePoints] += 1;
					format(string, sizeof(string), "(( %s has given you a role point, now you have: %d )).", NombreEx(playerid),PlayerInfo[giveplayerid][RolePoints]);
					SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
					format(string, sizeof(string), "(( You have given %s a role point, now has %d )).", NombreEx(giveplayerid),PlayerInfo[giveplayerid][RolePoints]);
					SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_LIGHTRED, "(( Player not connected )).");
			}
		}
		return 1;
	}
	if(!strcmp(cmd, "/removepoint"))
	{
		if(PlayerInfo[playerid][Admin] >= 2)
		{
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GREY, "Usage: /removepoint [ID/Name]");
				return 1;
			}
            giveplayerid = strval(tmp);
			if(IsPlayerConnected(giveplayerid))
			{
			    if(giveplayerid != INVALID_PLAYER_ID)
			    {
			        PlayerInfo[giveplayerid][RolePoints]-=1;

					format(string, sizeof(string), "(( The administrator %s substracted a role point from you, now you have %d )).", NombreEx(playerid),PlayerInfo[giveplayerid][RolePoints]);
					SendClientMessage(giveplayerid, COLOR_LIGHTRED, string);
					format(string, sizeof(string), "(( You have substracted %s a role point, now has %d )).", NombreEx(giveplayerid),PlayerInfo[giveplayerid][RolePoints]);
					SendClientMessage(playerid, COLOR_LIGHTRED, string);
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_LIGHTRED, "(( Player not connected )).");
			}
		}
		return 1;
	}
	if(!strcmp(cmd, "/ban"))
	{
    	tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /ban [ID/Name] [Reason]");
			return 1;
		}
		giveplayerid = strval(tmp);
		if (PlayerInfo[playerid][Admin] >= 2)
		{
			if(IsPlayerConnected(giveplayerid))
			{
			    if(giveplayerid != INVALID_PLAYER_ID)
			    {
					new length = strlen(cmdtext);
					while ((idx < length) && (cmdtext[idx] <= ' '))
					{
						idx++;
					}
					new offset = idx;
					new result[128];
					while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
					{
						result[idx - offset] = cmdtext[idx];
						idx++;
					}
					result[idx - offset] = EOS;
					if(!strlen(result))
					{
						SendClientMessage(playerid, COLOR_GREY, "Usage: /ban [ID/Name] [Reason]");
						return 1;
					}
					new year, month,day;
					getdate(year, month, day);
					format(string, sizeof(string), "Administration: %s has been banned by %s. Reason: %s (%d-%d-%d)", NombreEx(giveplayerid), NombreEx(playerid), (result),day,month,year);
					SendClientMessageToAll(COLOR_LIGHTRED, string);
					format(string, sizeof(string), "Administration: %s has been banned by %s. Reason: %s (%d-%d-%d)", NombreEx(giveplayerid), NombreEx(playerid), (result),day,month,year);
					BanLog(string);
					PlayerInfo[giveplayerid][Admin] = -3;
					Kick(giveplayerid);
					return 1;
				}
			}
		}
		return 1;
	}
	if(!strcmp(cmd, "/checkuser"))
	{
		if (PlayerInfo[playerid][Admin] >= 3)
		{
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GREY, "Usage: /checkuser [ID/Name]");
				return 1;
			}
            giveplayerid = strval(tmp);
			if(IsPlayerConnected(giveplayerid))
			{
			    if(giveplayerid != INVALID_PLAYER_ID)
			    {
					ShowStats(playerid,giveplayerid);
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_LIGHTRED, "(( Player not connected )).");
			}
		}
		return 1;
	}
	if(!strcmp(cmdtext, "/object"))
	{
		if (PlayerInfo[playerid][Admin] >= 3)
		{
		    PlayerInfo[playerid][Hand] = 0;
   			PlayerInfo[playerid][HandAmount] = 0;
   			RemovePlayerAttachedObject(playerid, 0);
   			CarryingBox[playerid] = 0;
   			ResetPlayerWeapons(playerid);
   			ShowPlayerDialog(playerid, 5, DIALOG_STYLE_INPUT, "Object", "Object ID:", "Select", "");
		}
		return 1;
	}
	if(!strcmp(cmd, "/makeleader"))
	{
		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /makeleader [ID/Name] [faction ID]");
			return 1;
		}
		new level;
		giveplayerid = strval(tmp);
		tmp = strtok(cmdtext, idx);
		level = strval(tmp);
		if (PlayerInfo[playerid][Admin] >= 3)
		{
		    if(IsPlayerConnected(giveplayerid))
		    {
		        if(giveplayerid != INVALID_PLAYER_ID)
		        {
					PlayerInfo[giveplayerid][Faction] = level;
					format(string, sizeof(string), "(( The administrator %s has assigned you as the leader of the faction %d )).", NombreEx(playerid),level);
					SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
					format(string, sizeof(string), "(( You have assigned %s the leadership of the faction %d )).", NombreEx(giveplayerid),level);
					SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
					if(level == 0) { PlayerInfo[giveplayerid][Rank] = 0; }
					else if(level == 1) { PlayerInfo[giveplayerid][Rank] = 5; }
					else if(level == 2) { PlayerInfo[giveplayerid][Rank] = 5; }
					else if(level == 3) { PlayerInfo[giveplayerid][Rank] = 3; }
					else if(level > 3) { PlayerInfo[giveplayerid][Rank] = 3; }
				}
			}
		}
		return 1;
	}
	if(!strcmp(cmd, "/makeadmin"))
	{
		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /makeadmin [ID/Name] [1-3]");
			return 1;
		}
		new level;
		giveplayerid = strval(tmp);
		tmp = strtok(cmdtext, idx);
		level = strval(tmp);
		if (PlayerInfo[playerid][Admin] >= 3)
		{
		    if(IsPlayerConnected(giveplayerid))
		    {
		        if(giveplayerid != INVALID_PLAYER_ID)
		        {
					PlayerInfo[giveplayerid][Admin] = level;
					format(string, sizeof(string), "(( The administrator %s has given you the administrator level of: %d )).", NombreEx(playerid),level);
					SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
					format(string, sizeof(string), "(( You have assigned %s the administrator level of %d )).", NombreEx(giveplayerid),level);
					SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
				}
			}
		}
		return 1;
	}
	if(!strcmp(cmd, "/setjob"))
	{
		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /setjob [ID/Name] [job ID]");
			SendClientMessage(playerid, COLOR_GREY, "1: Farmer            2: Dustman");
			SendClientMessage(playerid, COLOR_GREY, "3: Lorry driver");
			SendClientMessage(playerid, COLOR_GREY, "4: Pizza deliverer");
			SendClientMessage(playerid, COLOR_GREY, "5: Public transporter");
			SendClientMessage(playerid, COLOR_GREY, "6: Fisher            7: Mechanic");
			SendClientMessage(playerid, COLOR_GREY, "8: Criminal");
			return 1;
		}
		new level;
		giveplayerid = strval(tmp);
		tmp = strtok(cmdtext, idx);
		level = strval(tmp);
		if (PlayerInfo[playerid][Admin] >= 3)
		{
		    if(IsPlayerConnected(giveplayerid))
		    {
		        if(giveplayerid != INVALID_PLAYER_ID)
		        {
					PlayerInfo[giveplayerid][Job] = level;
					format(string, sizeof(string), "(( The administrator %s assigned you a job )).", NombreEx(playerid));
					SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
					format(string, sizeof(string), "(( You have set to %s the job %d )).", NombreEx(giveplayerid),level);
					SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
				}
			}
		}
    	return 1;
	}
	if(!strcmp(cmd, "/setcriminalskill"))
	{
		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp) && PlayerInfo[playerid][Admin] >= 3)
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /setcriminalskill [ID/Name] [number]");
			SendClientMessage(playerid, COLOR_GREY, "0: preparing a molotov and setting a business on fire (once)");
			SendClientMessage(playerid, COLOR_GREY, "1: robbing an ATM");
			SendClientMessage(playerid, COLOR_GREY, "2: searching a 9mm (once)");
			SendClientMessage(playerid, COLOR_GREY, "3: stealing a car");
			SendClientMessage(playerid, COLOR_GREY, "4: pickpocket");
			SendClientMessage(playerid, COLOR_GREY, "5: maximum");
			return 1;
		}
		new level;
		giveplayerid = strval(tmp);
		tmp = strtok(cmdtext, idx);
		level = strval(tmp);
		if (PlayerInfo[playerid][Admin] >= 3)
		{
		    if(IsPlayerConnected(giveplayerid))
		    {
		        if(giveplayerid != INVALID_PLAYER_ID)
		        {
					PlayerInfo[giveplayerid][CriminalSkill] = level;
					format(string, sizeof(string), "(( The administrator %s has changed your criminal skill )).", NombreEx(playerid));
					SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
					format(string, sizeof(string), "(( You have assigned %s the criminal skill of %d )).", NombreEx(giveplayerid),level);
					SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
				}
			}
		}
		return 1;
	}
	if(!strcmp(cmd, "/setmoney"))
	{
		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /setmoney [ID/Name] [money in tbe bank]");
			return 1;
		}
		new level;
		giveplayerid = strval(tmp);
		tmp = strtok(cmdtext, idx);
		level = strval(tmp);
		if (PlayerInfo[playerid][Admin] >= 3)
		{
		    if(IsPlayerConnected(giveplayerid))
		    {
		        if(giveplayerid != INVALID_PLAYER_ID)
		        {
					PlayerInfo[giveplayerid][Bank] = level;
					format(string, sizeof(string), "(( The administrator %s has assigned the amount of $ %d in your bank account )).", NombreEx(playerid), level);
					SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
					format(string, sizeof(string), "(( You have assigned %s the amount of %d in the bank ))", NombreEx(giveplayerid),level);
					SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
				}
			}
		}
		return 1;
	}
	if(!strcmp(cmdtext, "/saveall"))
	{
		if(PlayerInfo[playerid][Admin] >= 3)
		{
		    SaveThings();
		    SendClientMessage(playerid, COLOR_LIGHTGREEN, "(( Data of houses, business and vehicles saved )).");
		}
		return 1;
	}
	if(!strcmp(cmdtext, "/lottery"))
	{
        if(PlayerInfo[playerid][Admin] >= 3)
        {
            SendClientMessage(playerid, BALLAS_COLOR, "(( You started the lottery contest, the winning number is between 1 and 50, both included )).");
            new rand = random(50);
            rand += 1;
            Lotto(rand);
        }
		return 1;
	}
	if(!strcmp(cmd, "/id"))
	{
        tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
            format(string, sizeof(string), "* %s looks at her/his ID card.", NombreEx(playerid));
            ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		    SendClientMessage(playerid, COLOR_GREEN, "________| ID card |________");
	        format(string, sizeof(string), " Name: %s", NombreEx(playerid));
     		SendClientMessage(playerid, COLOR_LIGHTYELLOW, string);
     		format(string, sizeof(string), " Age: %d", PlayerInfo[playerid][Age]);
     		SendClientMessage(playerid, COLOR_LIGHTYELLOW, string);
    		if(PlayerInfo[playerid][Licence] > 0)
    		{
    		    format(string, sizeof(string), " Driving Licence points: %d", PlayerInfo[playerid][Licence]);
     			SendClientMessage(playerid, COLOR_YELLOW, string);
    		}
    		else
    		{
    		    SendClientMessage(playerid, COLOR_LIGHTRED, " No driving licence.");
    		}
    		SendClientMessage(playerid, COLOR_GREEN, "________________________");
		    return 1;
		}
		giveplayerid = strval(tmp);
		if(IsPlayerConnected(giveplayerid))
		{
		    if(giveplayerid != INVALID_PLAYER_ID)
		    {
		        if(ProxDetectorS(2.0, playerid, giveplayerid))
		        {
            		SendClientMessage(giveplayerid, COLOR_GREEN, "________| ID card |________");
	 		        format(string, sizeof(string), " Name: %s", NombreEx(playerid));
	         		SendClientMessage(giveplayerid, COLOR_LIGHTYELLOW, string);
	         		format(string, sizeof(string), " Age: %d", PlayerInfo[playerid][Age]);
	         		SendClientMessage(giveplayerid, COLOR_LIGHTYELLOW, string);
        			if(PlayerInfo[playerid][Licence] > 0)
	        		{
  		    			format(string, sizeof(string), " Driving Licence points: %d", PlayerInfo[playerid][Licence]);
     					SendClientMessage(giveplayerid, COLOR_YELLOW, string);
	        		}
	        		else
	        		{
  		    			SendClientMessage(giveplayerid, COLOR_LIGHTRED, " No driving licence.");
	        		}
	        		SendClientMessage(giveplayerid, COLOR_GREEN, "________________________");
            		format(string, sizeof(string), "* %s shows the ID card to %s.", NombreEx(playerid), NombreEx(giveplayerid));
  		            ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
            		return 1;
		        }
		    }
		}
	    return 1;
	}
	if(!strcmp(cmd, "/pay"))
	{
		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /pay [ID/Name] [money]");
			return 1;
		}
		giveplayerid = strval(tmp);
		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /pay [ID/Name] [money]");
			return 1;
		}
		moneys = strval(tmp);
		if(moneys < 1 || moneys > 99999)
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED, "(( Wrong amount )).");
		    return 1;
		}
		if (IsPlayerConnected(giveplayerid))
		{
		    if(giveplayerid != INVALID_PLAYER_ID)
		    {
		        if(PlayerInfo[playerid][Level] < 1)
				{
					SendClientMessage(playerid, COLOR_LIGHTRED, "(( Access denied )).");
					return 1;
				}
				if (ProxDetectorS(2.0, playerid, giveplayerid))
				{
				    if(giveplayerid == playerid)
				    {
				        SendClientMessage(playerid, COLOR_LIGHTRED, "(( You cannot give money to yourself )).");
				        return 1;
				    }
					playermoney = GetPlayerMoney(playerid);
					if (moneys > 0 && playermoney >= moneys)
					{
						GivePlayerMoney(playerid, (0 - moneys));
						GivePlayerMoney(giveplayerid, moneys);
						format(string, sizeof(string), "* You have given $%d to %s.", moneys, NombreEx(giveplayerid));
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						format(string, sizeof(string), "* %s has given $%d to you.", NombreEx(playerid), moneys);
						SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
						format(string, sizeof(string), "Admin: %s has given $%d to %s.", NombreEx(playerid), moneys, NombreEx(giveplayerid));
						PayLog(string);
						if(moneys >= 1000)
						{
                            format(string, sizeof(string), "(( Admin Info: %s has given $%d to %s )).", NombreEx(playerid), moneys, NombreEx(giveplayerid));
							ABroadCast(COLOR_RED,string,1);
						}
						PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
						PlayerPlaySound(giveplayerid, 1052, 0.0, 0.0, 0.0);
						format(string, sizeof(string), "* %s has given some money to %s.", sendername ,giveplayer);
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						ApplyAnimation(playerid,"DEALER","shop_pay",4.1,0,0,0,0,0);
					}
					else
					{
						SendClientMessage(playerid, COLOR_LIGHTRED, "(( Not correct amount )).");
					}
				}
				else
				{
					SendClientMessage(playerid, COLOR_LIGHTRED, "(( You are too far from that person )).");
				}
			} // invalid id.
		}
		return 1;
	}
	if(!strcmp(cmdtext, "/atm"))
	{
	    if(PlayerToPoint(2.0, playerid, 1336.95, -1745, 13.2) || PlayerToPoint(2.0, playerid, 1834.2, -1851, 13))
		{
		    format(string,sizeof(string),"Balance: %d\n-----\nTake money\nDeposit",PlayerInfo[playerid][Bank]);
        	ShowPlayerDialog(playerid,15,DIALOG_STYLE_LIST,"Automated Teller Machine",string,"Press","Cancel");
		}
		else if(PlayerToPoint(2.0, playerid, 1151.6, -1385.5, 13.4) || PlayerToPoint(2.0, playerid, 560.90002, -1293.999, 16.89))
		{
		    format(string,sizeof(string),"Balance: %d\n-----\nTake money\nDeposit",PlayerInfo[playerid][Bank]);
        	ShowPlayerDialog(playerid,15,DIALOG_STYLE_LIST,"Automated Teller Machine",string,"Press","Cancel");
		}
		else
		{
	        SendClientMessage(playerid, COLOR_LIGHTRED, "You are not next to an Automated Teller Machine.");
 		}
		return 1;
	}
	if(!strcmp(cmdtext, "/buy"))
	{
	    if(GetPlayerMoney(playerid)<1)
	    {
	        SendClientMessage(playerid, COLOR_LIGHTRED, "You don't have enough cash.");
	        return 1;
	    }
	    new idNegocio = NegVw[playerid];
	    switch(Business[idNegocio][Type])
	    {
	        case 0: SendClientMessage(playerid, COLOR_LIGHTRED, "Seemingly you aren't within a shop that sells products.");
	        case 1: ShowPlayerDialog(playerid,19, DIALOG_STYLE_LIST, "Grocery", "Bat - $10\nBriefcase - $30\nCamera - $40\nPhone - $50", "Buy", "Exit");
	        case 2: ShowPlayerDialog(playerid,19, DIALOG_STYLE_LIST, "Gym", "Water - $2\nSoda - $3\nBox suit (black) - $5\nBox suit (white) - $5", "Buy", "Exit");
			case 3: ShowPlayerDialog(playerid,19, DIALOG_STYLE_LIST, "Bar", "Water - $2\nSoda - $3\nCigarette - $4\nBeer - $5", "Buy", "Exit");
			case 4: ShowPlayerDialog(playerid,19, DIALOG_STYLE_LIST, "Pizzeria", "Water - $2\nSoda - $3\nPizza slice - $5\nPizza - $10", "Buy", "Exit");
			case 5: ShowPlayerDialog(playerid,19, DIALOG_STYLE_LIST, "Florist", "Water - $2\nKnife - $10\nShovel - $20\nFertiliser - $50", "Buy", "Exit");
			case 6:
			{
                if(Business[idNegocio][Products] < 1)
				{
					SendClientMessage(playerid, COLOR_LIGHTRED, "This clothing shop ran out of products.");
					return 1;
				}
				if(GetPlayerMoney(playerid) < 20) { SendClientMessage(playerid, COLOR_LIGHTRED, "You need 20 dollars."); return 1; }
	  			if(PlayerInfo[playerid][Sex] == 1) { ShowModelSelectionMenu(playerid, skinlist, "Choose a skin"); }
			    else { ShowModelSelectionMenu(playerid, skinlistmujer, "Choose a skin"); }
			}
			case 7: ShowPlayerDialog(playerid,19, DIALOG_STYLE_LIST, "Workshop", "Water - $2\nHelmet - $10\nPicklock - $30\nGasoline can - $50", "Buy", "Exit");
			case 8: ShowPlayerDialog(playerid,19, DIALOG_STYLE_LIST, "Betting shop", "Water - $2\nBeer - $5\nDice - $5\nLottery ticket - $10", "Buy", "Exit");
			case 9: SendClientMessage(playerid, COLOR_LIGHTRED, "No products yet.");
			case 10: ShowPlayerDialog(playerid,19, DIALOG_STYLE_LIST, "Ammu-Nation", "9mm clip - $200\nRifle clip - $500\n9mm - $1000\nRifle - $1500", "Buy", "Exit");
		}
		return 1;
	}
	if(!strcmp("/job", cmdtext))
	{
	    if(0 < PlayerInfo[playerid][Faction] < 4 || PlayerInfo[playerid][Job] != 0)
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED,"You already have a job.");
		    return 1;
		}
		else if(PlayerToPoint(3, playerid, -382.7005,-1426.2778,26.2496))
	    {
	        SendClientMessage(playerid, 0xFFFFFFFF, "{FFFFFF}[Boss] Congratulations, you have been hired as {FF00FF}farmer{FFFFFF}.");
	        SendClientMessage(playerid, COLOR_LIGHTYELLOW,"[Boss] When you wanna stop working, just get outta the combine harvester.");
	        SendClientMessage(playerid, COLOR_LIGHTYELLOW,"[Boss] Payments will be sent to your bank account when you work.");
	        PlayerInfo[playerid][Job] = 1;
	        return 1;
      	}
      	else if(PlayerToPoint(3, playerid,2195.6436,-1973.2948,13.5589))
	    {
	        SendClientMessage(playerid, 0xFFFFFFFF, "{FFFFFF}[Boss] Congratulations, you have been hired as {FF00FF}dustman{FFFFFF}.");
	        SendClientMessage(playerid, COLOR_LIGHTYELLOW,"[Boss] Don't get outta your vehicle while you're working.");
	        SendClientMessage(playerid, COLOR_LIGHTYELLOW,"[Boss] Payments will be sent to your bank account when you finish a route.");
	        PlayerInfo[playerid][Job] = 2;
	        return 1;
      	}
      	else if(PlayerToPoint(3, playerid, 2731.6450,-2416.8840,13.6278))
	    {
	        SendClientMessage(playerid, 0xFFFFFFFF, "{FFFFFF}[Boss] Congratulations, you have been hired as {FF00FF}lorry driver{FFFFFF}.");
	        SendClientMessage(playerid, COLOR_LIGHTYELLOW,"[Boss] Don't get outta your vehicle while you're working.");
	        SendClientMessage(playerid, COLOR_LIGHTYELLOW,"[Boss] Payments will be sent to your bank account when you finish a route.");
	        PlayerInfo[playerid][Job] = 3;
	        return 1;
      	}
      	else if(PlayerToPoint(3, playerid, 378.4542,-114.2976,1001.4922))
	    {
	        SendClientMessage(playerid, 0xFFFFFFFF, "{FFFFFF}[Boss] Congratulations, you have been hired as {FF00FF}pizza deliverer{FFFFFF}.");
	        SendClientMessage(playerid, COLOR_LIGHTYELLOW,"[Boss] Please, don't use the motorbike for personal purposes, only for working.");
	        PlayerInfo[playerid][Job] = 4;
	        return 1;
      	}
      	else if(PlayerToPoint(3, playerid, 1219.2954,-1812.5404,16.5938))
	    {
	        SendClientMessage(playerid, 0xFFFFFFFF, "{FFFFFF}[Boss] Congratulations, you have been hired as {FF00FF}public transporter{FFFFFF}.");
	        SendClientMessage(playerid, COLOR_LIGHTYELLOW,"[Boss] Please, don't use the taxis for personal purposes, only for working.");
	        SendClientMessage(playerid, COLOR_LIGHTYELLOW,"[Boss] If you are in a bus route, don't leave the vehicle.");
	        PlayerInfo[playerid][Job] = 5;
	        return 1;
      	}
      	else if(PlayerToPoint(3, playerid, 2411.8665,-2547.5198,13.6517))
	    {
	        SendClientMessage(playerid, 0xFFFFFFFF, "{FFFFFF}[Boss] Congratulations, you have been hired as {FF00FF}fisher{FFFFFF}.");
	        SendClientMessage(playerid, COLOR_LIGHTYELLOW,"[Boss] Please be careful out there in the sea and don't get very far from the coast.");
	        PlayerInfo[playerid][Job] = 6;
	        return 1;
      	}
      	else if(PlayerToPoint(3, playerid, 1295.3774,-985.6821,32.6953))
	    {
	        if(PlayerInfo[playerid][RolePoints] < 1) { SendClientMessage(playerid, COLOR_LIGHTRED, "(( You need one role point to get the job of criminal ))."); return 1; }
	        SendClientMessage(playerid, 0xFFFFFFFF, "{FFFFFF}[Mobster] I will trust you... you become my {FF00FF}criminal{FFFFFF}, be careful with the police.");
	        SendClientMessage(playerid, COLOR_LIGHTYELLOW,"[Mobster] Let me know when you wanna do /mission for me.");
	        PlayerInfo[playerid][Job] = 8;
	        return 1;
      	}
      	else
      	{
      	    SendClientMessage(playerid, COLOR_LIGHTRED, "Nobody is offering a job here, yellow circles on your map stand for job offers.");
      	}
		return 1;
	}
	if(!strcmp("/quitjob", cmdtext))
	{
	    if(PlayerInfo[playerid][Job] == 7)
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED,"If you wanna quit being a mechanic, you ought to talk with the owner of the workshop you work for.");
		    return 1;
		}
		else if(PlayerInfo[playerid][Job] == 0)
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED,"You don't have a job.");
		    return 1;
		}
		else
		{
		    PlayerInfo[playerid][Job] = 0;
		    DisablePlayerCheckpoint(playerid);
		    SendClientMessage(playerid, COLOR_LIGHTYELLOW, "[Boss] Well... you don't wanna work for me anymore... without resentment... bye.");
		}
		return 1;
	}
	if(!strcmp(cmd, "/call"))
    {
		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /call [number]");
			SendClientMessage(playerid, COLOR_GREY, "111: Pizza");
			SendClientMessage(playerid, COLOR_GREY, "444: Taxi");
			SendClientMessage(playerid, COLOR_GREY, "555: Mechanic");
			SendClientMessage(playerid, COLOR_GREY, "911: Emergencies");
			SendClientMessage(playerid, COLOR_GREY, "---");
			return 1;
		}
		if(PlayerInfo[playerid][Hand] != 34)
	    {
	        SendClientMessage(playerid, COLOR_LIGHTRED,"You need a phone.");
			return 1;
	    }
	    if(Call[playerid] != -1)
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED,"You're already in a call.");
			return 1;
		}
	    new dialed = strval(tmp);
	    if(dialed < 100)
		{
			SendClientMessage(playerid, COLOR_LIGHTRED,"Invalid number.");
		    return 1;
		}
 		format(string, sizeof(string), "* %s types some numbers in the phone.", NombreEx(playerid));
		ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		SetPlayerSpecialAction(playerid,SPECIAL_ACTION_USECELLPHONE);
		if(dialed == 111)
		{
            SendClientMessage(playerid, COLOR_LIGHTYELLOW,"[Operador] Tell where you need the pizza.");
            Call[playerid] = 111;
		}
		else if(dialed == 444)
		{
            SendClientMessage(playerid, COLOR_LIGHTYELLOW,"[Operador] Tell where you need the taxi.");
            Call[playerid] = 444;
		}
		else if(dialed == 555)
		{
            SendClientMessage(playerid, COLOR_LIGHTYELLOW,"[Operator] Tell where you need the mechanic.");
            Call[playerid] = 555;
		}
		else if(dialed == 911)
		{
            SendClientMessage(playerid, COLOR_LIGHTYELLOW,"[Operator] Emergency line, explain shortly what happened and the place.");
            Call[playerid] = 911;
		}
		else if(dialed > 1000)
		{
		    for(new i = 0; i < MAX_PLAYERS; i++)
			{
				//if(IsPlayerConnected(i)) { }
				if(PlayerInfo[i][PhoneNumber] == dialed)
				{
					giveplayerid = i;
					Call[playerid] = giveplayerid;
					//if(IsPlayerConnected(giveplayerid)) { }
					//if(giveplayerid != INVALID_PLAYER_ID) { }
					if(Call[giveplayerid] == -1)
					{
						format(string, sizeof(string), "%d is calling you (( /answer - /hangup )).", PlayerInfo[playerid][PhoneNumber]);
						SendClientMessage(giveplayerid, COLOR_YELLOW, string);
						GetPlayerName(giveplayerid, sendername, sizeof(sendername));
						format(string, sizeof(string), "* The phone of %s is ringing.", sendername);
						ProxDetector(30.0, i, string, COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN);
						return 1;
					}
				}
			}
		}
		else
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED,"No signal.");
		}
		return 1;
	}
	if(!strcmp(cmdtext, "/answer"))
	{
		if(Call[playerid] != -1)
		{
			SendClientMessage(playerid, COLOR_LIGHTRED, "You're already in a call.");
			return 1;
		}
		if(PlayerInfo[playerid][Hand] != 34)
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED, "You need a phone in your hand.");
			return 1;
		}
		for(new i = 0; i < MAX_PLAYERS; i++)
		{
			if(IsPlayerConnected(i))
			{
				if(Call[i] == playerid)
				{
					Call[playerid] = i; // ID of the caller.
					Call[i] = playerid; // ID of the one who picks up.
					SendClientMessage(playerid, COLOR_LIGHTGREEN, "They picked up, /hangup the call when you're done.");
					GetPlayerName(playerid, sendername, sizeof(sendername));
					format(string, sizeof(string), "* %s has picked up the phone.", sendername);
					SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				}
			}
		}
		return 1;
	}
	if(!strcmp(cmdtext, "/hangup"))
	{
		new caller = Call[playerid];
		if(caller == -1 || PlayerInfo[playerid][Hand] != 34) { return 1; }
		if(Call[caller] == playerid)
		{
			SendClientMessage(caller, COLOR_LIGHTRED, "She/he hanged up.");
			Call[caller] = -1;
			LoopingAnim(caller,"ped","phone_out",4.1,0,1,1,1,1);
		}
		Call[playerid] = -1;
		SendClientMessage(playerid, COLOR_LIGHTRED, "You have hanged up.");
        LoopingAnim(playerid,"ped","phone_out",4.1,0,1,1,1,1);
		return 1;
	}
	if(!strcmp(cmd, "/sms"))
	{
        if(PlayerInfo[playerid][Hand]!=34)
        {
            SendClientMessage(playerid, COLOR_LIGHTRED, "You need a phone.");
            return 1;
        }
		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /sms [ID/Name] [text]");
			return 1;
		}
		giveplayerid = strval(tmp);
		if (IsPlayerConnected(giveplayerid))
		{
		    if(giveplayerid != INVALID_PLAYER_ID)
		    {
				if(giveplayerid == playerid)
				{
					return 1;
				}
				new length = strlen(cmdtext);
				while ((idx < length) && (cmdtext[idx] <= ' '))
				{
					idx++;
				}
				new offset = idx;
				new result[128];
				while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
				{
					result[idx - offset] = cmdtext[idx];
					idx++;
				}
				result[idx - offset] = EOS;
				if(!strlen(result))
				{
					SendClientMessage(playerid, COLOR_GREY, "Usage: /sms [ID/Name] [text]");
					return 1;
				}
				if(PlayerInfo[giveplayerid][Hand]!=34 && PlayerInfo[giveplayerid][One]!=34 && PlayerInfo[giveplayerid][Two]!=34 && PlayerInfo[giveplayerid][Three]!=34 && PlayerInfo[giveplayerid][Four]!=34 && PlayerInfo[giveplayerid][Five]!=34)
		        {
		            SendClientMessage(playerid, COLOR_LIGHTRED, "That person doesn't have a phone.");
		            return 1;
		        }
				format(string, sizeof(string), "SMS from %s: %s", NombreEx(playerid), (result));
				SendClientMessage(giveplayerid, COLOR_YELLOW, string);
				format(string, sizeof(string), "SMS sent to %s: %s", NombreEx(giveplayerid), (result));
				SendClientMessage(playerid,  COLOR_LIGHTYELLOW, string);
				return 1;
			}
		}
		else
		{
				SendClientMessage(playerid, COLOR_GREY, "(( Player not connected )).");
		}
		return 1;
	}
	if(!strcmp(cmdtext, "/engine"))
	{
		if(IsPlayerInAnyVehicle(playerid))
		{
		    if(GetPlayerState(playerid) == PLAYER_STATE_PASSENGER) { return 1; }
		    if(Bicicletas(GetPlayerVehicleID(playerid))) { return 1; }
			if(Motor[GetPlayerVehicleID(playerid)] == 0)
    		{
    		    if(Gas[GetPlayerVehicleID(playerid)] == 0)
    		    {
    		        SendClientMessage(playerid, COLOR_LIGHTRED, "No fuel.");
    		        return 1;
    		    }
				new Float:VVC;
            	GetVehicleHealth(GetPlayerVehicleID(playerid),VVC);
				if(VVC < 500)
				{
				    GameTextForPlayer(giveplayerid, "~r~engine broken", 2500, 3);
				    SendClientMessage(playerid, COLOR_LIGHTRED,"* You cannot turn the engine on, so you should /call a mechanic.");
				    return 1;
				}
				if(GetPlayerVehicleID(playerid) < 21 && PlayerInfo[playerid][Faction] != 1)
                {
                    SendClientMessage(playerid, COLOR_LIGHTRED,"This vehicle belongs to LSPD.");
					return 1;
				}
				if(21 <= GetPlayerVehicleID(playerid) <= 26 && PlayerInfo[playerid][Faction] != 2)
                {
                    SendClientMessage(playerid, COLOR_LIGHTRED,"This vehicle belongs to LSMD.");
					return 1;
				}
				if(27 <= GetPlayerVehicleID(playerid) <= 29 && PlayerInfo[playerid][Faction] != 3)
                {
                    SendClientMessage(playerid, COLOR_LIGHTRED,"This vehicle belongs to San Andreas News.");
					return 1;
				}
				if(GetPlayerVehicleID(playerid) == 30 && PlayerInfo[playerid][Job] != 1)
                {
                    SendClientMessage(playerid, COLOR_LIGHTRED,"You are not a farmer.");
					return 1;
				}
				if(31 <= GetPlayerVehicleID(playerid) <= 32 && PlayerInfo[playerid][Job] != 2)
                {
                    SendClientMessage(playerid, COLOR_LIGHTRED,"You are not a dustman.");
					return 1;
				}
				if(33 <= GetPlayerVehicleID(playerid) <= 37 && PlayerInfo[playerid][Job] != 3)
                {
                    SendClientMessage(playerid, COLOR_LIGHTRED,"You are not a lorry driver.");
					return 1;
				}
				if(GetPlayerVehicleID(playerid) == 39 && PlayerInfo[playerid][Job] != 4)
                {
                    SendClientMessage(playerid, COLOR_LIGHTRED,"You are not a pizza deliverer.");
					return 1;
				}
				if(40 <= GetPlayerVehicleID(playerid) <= 43 && PlayerInfo[playerid][Job] != 5)
                {
                    SendClientMessage(playerid, COLOR_LIGHTRED,"You are not a public transporter.");
					return 1;
				}
				if(44 <= GetPlayerVehicleID(playerid) <= 45 && PlayerInfo[playerid][Job] != 6)
                {
                    SendClientMessage(playerid, COLOR_LIGHTRED,"You are not a fisher.");
					return 1;
				}
				if(GetPlayerVehicleID(playerid) == 46 && PlayerInfo[playerid][BusinessKey] != 10)
                {
                    SendClientMessage(playerid, COLOR_LIGHTRED,"You don't work for East Beach Workshop.");
					return 1;
				}
				if(GetPlayerVehicleID(playerid) == 47 && PlayerInfo[playerid][BusinessKey] != 11)
                {
                    SendClientMessage(playerid, COLOR_LIGHTRED,"You don't work for East Los Santos Workshop.");
					return 1;
				}
				if(GetPlayerVehicleID(playerid) == 48 && PlayerInfo[playerid][BusinessKey] != 12)
                {
                    SendClientMessage(playerid, COLOR_LIGHTRED,"You don't work for Commerce Workshop.");
					return 1;
				}
				if(GetPlayerVehicleID(playerid) == 49 && PlayerInfo[playerid][BusinessKey] != 13)
                {
                    SendClientMessage(playerid, COLOR_LIGHTRED,"You don't work for Seville Workshop.");
					return 1;
				}
				if(GetPlayerVehicleID(playerid) == 50 && PlayerInfo[playerid][BusinessKey] != 14)
                {
                    SendClientMessage(playerid, COLOR_LIGHTRED,"You don't work for Ganton Workshop.");
					return 1;
				}
				if(50 < GetPlayerVehicleID(playerid))
                {
                    new llave = PlayerInfo[playerid][VehicleKey];
                    new idreal = GetPlayerVehicleID(playerid);
                    new posicionCarro = idreal-51;
                    new llave2 = PlayerInfo[playerid][VehicleKey2];
                	if(llave != Carros[posicionCarro] && llave2 != Carros[posicionCarro])
                	{
                    	SendClientMessage(playerid, COLOR_LIGHTRED,"You don't have the key of this private vehicle.");
                    	return 1;
                    }
				}
				new playerveh = GetPlayerVehicleID(playerid);
				PutPlayerInVehicle(playerid, playerveh, 0);
				format(string, sizeof(string), "* %s turns on the engine of the vehicle.", NombreEx(playerid));
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				GameTextForPlayer(playerid, "~w~Starting...",3500,3);
				SetTimerEx("StartingTheVehicle", 2000, 0, "i", playerid);
				Motor[GetPlayerVehicleID(playerid)] = 1;
				return 1;
			}
			if(Motor[GetPlayerVehicleID(playerid)] == 1)
    		{
				new playerveh = GetPlayerVehicleID(playerid);
				format(string, sizeof(string), "* %s turns off the engine of the vehicle.", NombreEx(playerid));
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				Motor[playerveh] = 0;
				Motor[GetPlayerVehicleID(playerid)] = 0;
				new veh = GetPlayerVehicleID(playerid);
                new engine,lights,alarm,doors,bonnet,boot,objective;
                GetVehicleParamsEx(veh,engine,lights,alarm,doors,bonnet,boot,objective);
                SetVehicleParamsEx(veh,VEHICLE_PARAMS_OFF,lights,0,doors,bonnet,boot,objective);
				return 1;
			}
		}
	    return 1;
	}
	if(!strcmp(cmdtext, "/staff"))
    {
    	SendClientMessage(playerid, COLOR_GREEN, "|____ Staff online ____|");
    	for(new i = 0; i < MAX_PLAYERS; i++)
    	{
	    	if(IsPlayerConnected(i))
	    	{
	    		new admtext[128];
	    		if(PlayerInfo[i][Admin] == 3) { admtext = "Big Administrator"; }
	    		else if(PlayerInfo[i][Admin] == 2) { admtext = "Administrator"; }
	    		else if(PlayerInfo[i][Admin] == 1) { admtext = "Moderator"; }
	    		if(4 > PlayerInfo[i][Admin] > 0)
	    		{
	    		    format(string, 256, "%s: %s ", admtext, NombreEx(playerid));
	    		    SendClientMessage(playerid, COLOR_WHITE, string);
	    		}
	   		}
  		}
  		SendClientMessage(playerid, COLOR_GREY, "(( Ask us a /doubt if you want )).");
    	return 1;
	}
	if(!strcmp(cmd, "/doubt"))
	{
		new length = strlen(cmdtext);
		while ((idx < length) && (cmdtext[idx] <= ' '))
		{
			idx++;
		}
		new offset = idx;
		new result[128];
		while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
		{
			result[idx - offset] = cmdtext[idx];
			idx++;
		}
		result[idx - offset] = EOS;
		if(!strlen(result))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /doubt [question or request to the staff online]");
			return 1;
		}
		format(string, sizeof(string), "(( Doubt of %s: %s )).", NombreEx(playerid), result);
		ABroadCast(BALLAS_COLOR,string,1);
		printf("%s", string);
		SendClientMessage(playerid, BALLAS_COLOR, "(( Doubt sent )).");
		return 1;
	}
	if(!strcmp(cmd, "/pm"))
	{
		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /pm [ID/Name] [text]");
			SendClientMessage(playerid, COLOR_GREY, "(( For OOC messages )).");
			return 1;
		}
		giveplayerid = strval(tmp);
		if (IsPlayerConnected(giveplayerid))
		{
		    if(giveplayerid != INVALID_PLAYER_ID)
		    {
				if(giveplayerid == playerid)
				{
					return 1;
				}
				new length = strlen(cmdtext);
				while ((idx < length) && (cmdtext[idx] <= ' '))
				{
					idx++;
				}
				new offset = idx;
				new result[128];
				while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
				{
					result[idx - offset] = cmdtext[idx];
					idx++;
				}
				result[idx - offset] = EOS;
				if(!strlen(result))
				{
					SendClientMessage(playerid, COLOR_GREY, "Usage: /pm [ID/Name] [text]");
					return 1;
				}
				format(string, sizeof(string), "(( Private message from %s: %s )).", NombreEx(playerid), (result));
				SendClientMessage(giveplayerid, COLOR_YELLOW, string);
				format(string, sizeof(string), "(( Message to %s: %s )).", NombreEx(giveplayerid), (result));
				SendClientMessage(playerid,  COLOR_LIGHTYELLOW, string);
				return 1;
			}
		}
		else
		{
				SendClientMessage(playerid, COLOR_GREY, "(( Player not connected )).");
		}
		return 1;
	}
	if(!strcmp("/pocket", cmdtext) || !strcmp("/inventory", cmdtext))
    {
        if(CarryingBox[playerid] == 1)
        {
            SendClientMessage(playerid, COLOR_LIGHTRED, "While carrying a box you cannot check your pockets.");
            return 1;
        }
		if(0 < PlayerInfo[playerid][Hand] < 14) { PlayerInfo[playerid][HandAmount] = GetPlayerAmmo(playerid); }
		new cantidad1 = PlayerInfo[playerid][OneAmount];
		new cantidad2 = PlayerInfo[playerid][TwoAmount];
		new cantidad3 = PlayerInfo[playerid][ThreeAmount];
		new cantidad4 = PlayerInfo[playerid][FourAmount];
		new cantidad5 = PlayerInfo[playerid][FiveAmount];
        format(string,sizeof(string),"%s (%d)\n%s (%d)\n%s (%d)\n%s (%d)\n%s (%d)\n----------\n%s (%d)",Obje[PlayerInfo[playerid][One]],cantidad1,Obje[PlayerInfo[playerid][Two]],cantidad2,Obje[PlayerInfo[playerid][Three]],cantidad3,Obje[PlayerInfo[playerid][Four]],cantidad4,Obje[PlayerInfo[playerid][Five]],cantidad5,Obje[PlayerInfo[playerid][Hand]],PlayerInfo[playerid][HandAmount]);
        ShowPlayerDialog(playerid,8,DIALOG_STYLE_LIST,"Pocket",string,"Take","Exit");
   		return 1;
	}
	if(!strcmp("/back", cmdtext))
   	{
    	if(PlayerInfo[playerid][Back] == 0)
	 	{
			switch(PlayerInfo[playerid][Hand])
	 	    {
				case 3,4,5,7,8,9:
				{
                    new gunAmmo = GetPlayerAmmo(playerid);
					PlayerInfo[playerid][Back] = PlayerInfo[playerid][Hand];
					PlayerInfo[playerid][BackAmount] = gunAmmo;
					PlayerInfo[playerid][Hand] = 0;
 					PlayerInfo[playerid][HandAmount] = 0;
 					ResetPlayerWeapons(playerid);
  					RemovePlayerAttachedObject(playerid, 0);
  					ResetObject(playerid);
				}
				default:
				{
                    SendClientMessage(playerid, COLOR_LIGHTRED, "You don't have a big weapon to put on your back.");
				}
			}
       	}
		else if(PlayerInfo[playerid][Back] != 0 && PlayerInfo[playerid][Hand] == 0)
    	{
    	    RemovePlayerAttachedObject(playerid,BackSlot);
  		    PlayerInfo[playerid][Hand] = PlayerInfo[playerid][Back];
  		    PlayerInfo[playerid][HandAmount] = PlayerInfo[playerid][BackAmount];
  		    PlayerInfo[playerid][Back] = 0;
      		PlayerInfo[playerid][BackAmount] = 0;
      		ResetObject(playerid);
		}
		else
		{
			SendClientMessage(playerid, COLOR_LIGHTRED, "You cannot take something from your back if you have an object in your hand.");
		}

   		return 1;
   	}
   	if(!strcmp(cmdtext, "/keep"))
    {
     	new CantidadEnMano = PlayerInfo[playerid][HandAmount];
     	new gunAmmo = GetPlayerAmmo(playerid);
     	switch(PlayerInfo[playerid][Hand])
     	{
   			case 0: {
                SendClientMessage(playerid, COLOR_LIGHTRED, "Your hands are empty.");
                return 1;
			}
			case 3,4,5,8,9,11,15,16,39,40,41,42,43,44,45,46: {
			    SendClientMessage(playerid, COLOR_LIGHTRED, "This object is too big.");
			    return 1;
			}
			case 13: {
                SendClientMessage(playerid, COLOR_LIGHTRED, "You cannot put the Molotov cocktail in your pocket, the rag is burning.");
                return 1;
			}
		}
     	if(PlayerInfo[playerid][One] != 0 && PlayerInfo[playerid][Two] != 0 && PlayerInfo[playerid][Three] != 0 && PlayerInfo[playerid][Four] != 0 && PlayerInfo[playerid][Five] != 0)
     	{
     		SendClientMessage(playerid, COLOR_LIGHTRED, "Your pockets are full.");
	 		return 1;
     	}
     	if(PlayerInfo[playerid][One] == 0)
     	{
      		PlayerInfo[playerid][One] = PlayerInfo[playerid][Hand];
	 		if(0 < PlayerInfo[playerid][Hand] < 14)
	 		{
                PlayerInfo[playerid][OneAmount] = gunAmmo;
	 		}
	 		else
	 		{
    			PlayerInfo[playerid][OneAmount] = CantidadEnMano;
    		}
    	}
	   	else if(PlayerInfo[playerid][One] != 0 && PlayerInfo[playerid][Two] == 0)
	   	{
     		PlayerInfo[playerid][Two] = PlayerInfo[playerid][Hand];
	 		if(0 < PlayerInfo[playerid][Hand] < 14)
	 		{
    			PlayerInfo[playerid][TwoAmount] = gunAmmo;
 			}
	 		else
	 		{
    			PlayerInfo[playerid][TwoAmount] = CantidadEnMano;
    		}
    	}
	   	else if(PlayerInfo[playerid][One] != 0 && PlayerInfo[playerid][Two] != 0 && PlayerInfo[playerid][Three] == 0)
	   	{
     		PlayerInfo[playerid][Three] = PlayerInfo[playerid][Hand];
	 		if(0 < PlayerInfo[playerid][Hand] < 14)
	 		{
                PlayerInfo[playerid][ThreeAmount] = gunAmmo;
	 		}
	 		else
	 		{
    			PlayerInfo[playerid][ThreeAmount] = CantidadEnMano;
    		}
    	}
	   	else if(PlayerInfo[playerid][One] != 0 && PlayerInfo[playerid][Two] != 0 && PlayerInfo[playerid][Three] != 0 && PlayerInfo[playerid][Four] == 0)
	   	{
   			PlayerInfo[playerid][Four] = PlayerInfo[playerid][Hand];
	 		if(0 < PlayerInfo[playerid][Hand] < 14)
	 		{
                PlayerInfo[playerid][FourAmount] = gunAmmo;
	 		}
	 		else
	 		{
                PlayerInfo[playerid][FourAmount] = CantidadEnMano;
    		}
   		}
	   	else if(PlayerInfo[playerid][One] != 0 && PlayerInfo[playerid][Two] != 0 && PlayerInfo[playerid][Three] != 0 && PlayerInfo[playerid][Four] != 0 && PlayerInfo[playerid][Five] == 0)
	   	{
     		PlayerInfo[playerid][Five] = PlayerInfo[playerid][Hand];
	 		if(0 < PlayerInfo[playerid][Hand] < 14)
	 		{
    			PlayerInfo[playerid][FiveAmount] = gunAmmo;
	 		}
	 		else
	 		{
    			PlayerInfo[playerid][FiveAmount] = CantidadEnMano;
    		}
   		}
	   	RemovePlayerAttachedObject(playerid, 0);
     	ResetPlayerWeapons(playerid);
	   	format(string, sizeof(string), " %s kept in the pocket.", Obje[PlayerInfo[playerid][Hand]]);
     	SendClientMessage(playerid, COLOR_GREY, string);
	   	PlayerInfo[playerid][Hand] = 0;
     	PlayerInfo[playerid][HandAmount] = 0;
    	return 1;
    }
    if(!strcmp(cmd,"/give",true))
    {
		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /give [ID/Name]");
			return 1;
		}
		giveplayerid = strval(tmp);
		if(IsPlayerConnected(giveplayerid))
		{
			if(giveplayerid != INVALID_PLAYER_ID)
			{
		    	if(giveplayerid == playerid) { SendClientMessage(playerid, COLOR_LIGHTRED, "You cannot give anything to yourself."); return 1; }
                if(PlayerInfo[playerid][Hand] == 0) { SendClientMessage(playerid, COLOR_LIGHTRED, "Your hands are empty."); return 1; }
                if(PlayerInfo[giveplayerid][Hand] != 0)
                {
                	format(string,sizeof(string),"%s has the hands busy.",NombreEx(giveplayerid));
                    SendClientMessage(playerid, COLOR_LIGHTRED, string);
                    format(string,sizeof(string),"%s wanna give you %s, but your hands are busy.",NombreEx(playerid), Obje[PlayerInfo[playerid][Hand]]);
                    SendClientMessage(giveplayerid, COLOR_LIGHTRED, string);
                    return 1;
                }
                if(!ProxDetectorS(2.0, playerid, giveplayerid))
			   	{
    				SendClientMessage(playerid, COLOR_LIGHTRED, "You are too far from that person.");
        			return 1;
			    }
      			format(string,sizeof(string),"* You give %s to %s.",Obje[PlayerInfo[playerid][Hand]], NombreEx(giveplayerid));
      			SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
      			format(string,sizeof(string),"* %s has given %s to you.",NombreEx(playerid), Obje[PlayerInfo[playerid][Hand]]);
      			SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
      			CarryingBox[playerid] = 0;
      			RemovePlayerAttachedObject(playerid, 0);
      			ResetPlayerWeapons(playerid);
  				if(PlayerInfo[playerid][Hand] > 13)
      			{
         			new CantidadEnMano = PlayerInfo[playerid][HandAmount];
         			PlayerInfo[giveplayerid][Hand] = PlayerInfo[playerid][Hand];
         			PlayerInfo[giveplayerid][HandAmount] = CantidadEnMano;
         			RemovePlayerAttachedObject(playerid, 0);
         			PlayerInfo[playerid][Hand] = 0;
         			PlayerInfo[playerid][HandAmount] = 0;
 			  		ResetObject(giveplayerid);
      			}
      			else if(PlayerInfo[playerid][Hand] <= 13)
      			{
         			new Municion = GetPlayerAmmo(playerid);
         			PlayerInfo[giveplayerid][Hand] = PlayerInfo[playerid][Hand];
         			PlayerInfo[giveplayerid][HandAmount] = Municion;
         			RemovePlayerAttachedObject(playerid, 0);
         			ResetPlayerWeapons(playerid);
         			PlayerInfo[playerid][Hand] = 0;
         			PlayerInfo[playerid][HandAmount] = 0;
         			ResetObject(giveplayerid);
      			}
			}
		}
		else
		{
 			SendClientMessage(playerid, COLOR_LIGHTRED, "(( The player is not connected )).");
   			return 1;
		}
	    return 1;
 	}
 	if(!strcmp("/helmet", cmdtext))
   	{
   	    if(PlayerInfo[playerid][Hand]==0 && Masked[playerid]==1)
   	    {
   	        for(new i = 0; i < MAX_PLAYERS; i++)
		  	{
				ShowPlayerNameTagForPlayer(i, playerid, 1);
		   	}
		   	PlayerInfo[playerid][Hand]=38;
		   	PlayerInfo[playerid][HandAmount]=1;
		   	Masked[playerid]=0;
            RemovePlayerAttachedObject(playerid, 4);
            ResetObject(playerid);
   	    }
   		return 1;
   	}
   	if(!strcmp("/drop", cmdtext))
   	{
   	    new gunAmmo = GetPlayerAmmo(playerid);
   	    if(PlayerInfo[playerid][Hand] == 0) { return 1; }
   	    new Float:plocx,Float:plocy,Float:plocz,Float:ploca;
		GetPlayerPos(playerid, plocx, plocy, plocz);
		GetPlayerFacingAngle(playerid,ploca);
		if(0 < PlayerInfo[playerid][Hand] < 14)
		{
  			CreateObjeto(plocx,plocy,plocz,ploca,PlayerInfo[playerid][Hand],gunAmmo);
		}
		else
		{
		    CreateObjeto(plocx,plocy,plocz,ploca,PlayerInfo[playerid][Hand],PlayerInfo[playerid][HandAmount]);
		}
   		format(string, sizeof(string), "(( Admin Info: %s has dropped %s on the ground )).", NombreEx(playerid), Obje[PlayerInfo[playerid][Hand]]);
		ABroadCast(COLOR_RED,string,1);
   		PlayerInfo[playerid][Hand] = 0;
   		PlayerInfo[playerid][HandAmount] = 0;
   		RemovePlayerAttachedObject(playerid, 0);
   		CarryingBox[playerid] = 0;
   		LoopingAnim(playerid, "CARRY", "putdwn105",4.1,0,0,0,0,0);
   		ResetPlayerWeapons(playerid);
    	format(string, sizeof(string), "* %s drops an object on the ground.", NombreEx(playerid));
    	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
   		return 1;
   	}
   	if(!strcmp(cmdtext, "/pickup"))
 	{
 	    if(PlayerInfo[playerid][Hand] != 0)
	 	{
	 	    SendClientMessage(playerid, COLOR_LIGHTRED, " Your hands are busy.");
		 	return 1;
	 	}
		DeleteClosestObjeto(playerid);
		return 1;
	}
   	if(!strcmp("/load", cmdtext))
   	{
        new objetoCargador;
		new idArma;
		new balas;
   	    switch(PlayerInfo[playerid][Hand])
   	    {
			case 1: { idArma = 22; objetoCargador = 18; balas = 17; }
            case 2: { idArma = 24; objetoCargador = 19; balas = 7; }
			case 3: { idArma = 33; objetoCargador = 20; balas = 5; }
			case 4: { idArma = 25; objetoCargador = 21; balas = 5; }
			case 5: { idArma = 34; objetoCargador = 22; balas = 5; }
			case 6: { idArma = 28; objetoCargador = 23; balas = 50; }
			case 7: { idArma = 29; objetoCargador = 24; balas = 30; }
			case 8: { idArma = 30; objetoCargador = 25; balas = 30; }
			case 9: { idArma = 31; objetoCargador = 26; balas = 50; }
		}
    	if(1 <= PlayerInfo[playerid][Hand] <= 9)
	 	{
	 	    if(PlayerInfo[playerid][One] == objetoCargador) { PlayerInfo[playerid][One]=0; PlayerInfo[playerid][OneAmount]=0; }
			else if(PlayerInfo[playerid][Two] == objetoCargador) { PlayerInfo[playerid][Two]=0; PlayerInfo[playerid][TwoAmount]=0; }
			else if(PlayerInfo[playerid][Three] == objetoCargador) { PlayerInfo[playerid][Three]=0; PlayerInfo[playerid][ThreeAmount]=0; }
			else if(PlayerInfo[playerid][Four] == objetoCargador) { PlayerInfo[playerid][Four]=0; PlayerInfo[playerid][FourAmount]=0; }
			else if(PlayerInfo[playerid][Five] == objetoCargador) { PlayerInfo[playerid][Five]=0; PlayerInfo[playerid][FiveAmount]=0; }
			else {
				SendClientMessage(playerid, COLOR_LIGHTRED, "No clips left.");
				return 1;
			}
   			ResetPlayerWeapons(playerid);
   			SendClientMessage(playerid, BALLAS_COLOR, "* Weapon loaded.");
            LoopingAnim(playerid,"UZI","UZI_reload",4.1,0,0,0,0,0);
            GivePlayerWeapon(playerid, idArma, balas);
		} else {
			SendClientMessage(playerid, COLOR_LIGHTRED, "You don't have a weapon in your hand.");
		}
   		return 1;
   	}
   	if(!strcmp(cmdtext,"/use",true))
    {
        switch(PlayerInfo[playerid][Hand])
        {
            case 0: SendClientMessage(playerid, COLOR_LIGHTRED, "You don't have anything in your hand to use.");
            case 48,50:
			{
                format(string, sizeof(string), "* %s takes a puff of %s.", NombreEx(playerid),Obje[PlayerInfo[playerid][Hand]]);
	        	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	         	LoopingAnim(playerid,"GANGS","smkcig_prtl",4.1,0,0,0,0,0);
	       		PlayerInfo[playerid][HandAmount] -= 1;
	          	if(PlayerInfo[playerid][HandAmount] <= 0)
	         	{
		         	SendClientMessage(playerid, COLOR_LIGHTRED, "The cigarette has been consumed.");
		         	RemovePlayerAttachedObject(playerid, 0);
		         	PlayerInfo[playerid][Hand] = 0;
	         	}
	         	if(PlayerInfo[playerid][Hand]==48)
	         	{
	   	    		SetPlayerWeather(playerid, 9);
	   	    		SetPlayerDrunkLevel(playerid, 4000);
	             	UsingDrugs[playerid] = 2;
	  	         	SetTimerEx("DrugEffectGone", 180000, false, "d", playerid); // 3 minutos
	  	         	SendClientMessage(playerid, COLOR_RED, "* You're getting dizzy.");
	  	         	PlayerInfo[playerid][Hand] = 0;
	         	}
			}
			case 49:
			{
			    SendClientMessage(playerid, COLOR_RED, "* You sniff some cocaine and get nervous as hell.");
                UsingDrugs[playerid] = 3;
                SetPlayerDrunkLevel(playerid, 4000);
                SetPlayerHealth(playerid,30);
                //SetPlayerWeather(playerid, 21);
                SetPlayerWeather(playerid, -68);
  	            SetTimerEx("DrugEffectGone", 300000, false, "d", playerid); // 5 minutos
  	            PlayerInfo[playerid][Hand] = 0;
			}
			case 31,32,33:
			{
                format(string, sizeof(string), "* %s takes a sip of %s.", NombreEx(playerid),Obje[PlayerInfo[playerid][Hand]]);
          		ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
          		LoopingAnim(playerid, "BAR", "dnk_stndM_loop",4.1,0,0,0,0,0);
          		SetPlayerHealth(playerid,100);
          		PlayerInfo[playerid][HandAmount] -= 1;
          		if(PlayerInfo[playerid][HandAmount] <= 0)
	         	{
	         	    SendClientMessage(playerid, COLOR_LIGHTRED, "You ran out of your drink.");
		         	RemovePlayerAttachedObject(playerid, 0);
	         		PlayerInfo[playerid][Hand] = 0;
	         	}
			}
			case 27,28,29,30:
			{
                format(string, sizeof(string), "* %s takes a bite of %s.", NombreEx(playerid),Obje[PlayerInfo[playerid][Hand]]);
	          	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	          	LoopingAnim(playerid,"FOOD","EAT_Burger",4.1,0,0,0,0,0);
	          	SetPlayerHealth(playerid,100);
	          	PlayerInfo[playerid][HandAmount] -= 1;
				if(PlayerInfo[playerid][HandAmount] <= 0)
	         	{
		         	SendClientMessage(playerid, COLOR_LIGHTRED, "You ran out of your food.");
		         	RemovePlayerAttachedObject(playerid, 0);
		         	PlayerInfo[playerid][Hand] = 0;
	         	}
			}
			case 38:
			{
                if(Masked[playerid]==0)
	    		{
			   		format(string, sizeof(string), "(( Admin Info: %s is hidding the identity with a helmet )).", NombreEx(playerid));
					ABroadCast(COLOR_RED,string,1);
	    		    RemovePlayerAttachedObject(playerid, 0);
	    		    SetPlayerAttachedObject(playerid,4,18645,2,0.07,0.017,0,88,75,0);
					PlayerInfo[playerid][Hand]=0;
					PlayerInfo[playerid][HandAmount]=0;
					Masked[playerid]=1;
				 	for(new i = 0; i < MAX_PLAYERS; i++)
	     			{
	  					ShowPlayerNameTagForPlayer(i, playerid, 0);
			     	}
	    		}
			}
			case 47:
			{
                if(PlayerInfo[playerid][HouseKey]==0) { SendClientMessage(playerid, COLOR_LIGHTRED, "You gotta own a house to plant the marijuana."); return 1; }
			    if(GetPlayerVirtualWorld(playerid)!=PlayerInfo[playerid][HouseKey]) { SendClientMessage(playerid, COLOR_LIGHTRED, "You're not at home."); return 1; }
			    new key = PlayerInfo[playerid][HouseKey];
			    if(House[key][Seed]!=0) { return 1; }
			    if(!PlayerToPoint(30.0, playerid, House[key][Exitx], House[key][Exity], House[key][Exitz])) return SendClientMessage(playerid, COLOR_LIGHTRED, "Seemingly you're not at home.");
		        SendClientMessage(playerid, COLOR_YELLOW, "* You have planted the seed on a pot.");
		        SendClientMessage(playerid, COLOR_GREEN, "You realise you need to /use a fertiliser sack to help the plant to grow.");
				PlayerInfo[playerid][Hand]=0;
				PlayerInfo[playerid][HandAmount]=0;
				House[key][Seed]=1;
                new Float:x, Float:y, Float:z;
    			GetPlayerPos(playerid,x,y,z);
    			House[key][Seedx]=x;
    			House[key][Seedy]=y;
    			House[key][Seedz]=z-1;
    			CreateDynamicObject(19473,x,y,z-1,0.0,0.0,0.0,key);
			}
			case 39:
			{
                if(PlayerInfo[playerid][HouseKey]==0) { SendClientMessage(playerid, COLOR_LIGHTRED, "You need a home to use the fertiliser sack."); return 1; }
			    if(GetPlayerVirtualWorld(playerid)!=PlayerInfo[playerid][HouseKey]) { SendClientMessage(playerid, COLOR_LIGHTRED, "You're not at home."); return 1; }
			    new key = PlayerInfo[playerid][HouseKey];
			    if(PlayerToPoint(30.0, playerid, House[key][Seedx], House[key][Seedy], House[key][Seedz])) return SendClientMessage(playerid, COLOR_LIGHTRED, "Seemingly you're not at home.");
		        if(House[key][Seed]!=1) { SendClientMessage(playerid, COLOR_LIGHTRED, "Fertiliser is not necessary."); return 1; }
		        SendClientMessage(playerid, COLOR_YELLOW, "* You dump fertiliser on your marijuana plant.");
		        SendClientMessage(playerid, COLOR_GREEN, "You realise now you need to /water the plant.");
				PlayerInfo[playerid][Hand]=0;
				PlayerInfo[playerid][HandAmount]=0;
				RemovePlayerAttachedObject(playerid, 0);
				CarryingBox[playerid]=0;
				LoopingAnim(playerid, "CARRY", "putdwn105",4.1,0,0,0,0,0);
				House[key][Seed]=2;
			}
			case 51:
			{
                new dice = random(6)+1;
		 		format(string, sizeof(string), "* %s throws a dice and the result is %d.", NombreEx(playerid),dice);
		 		ProxDetector(15.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			}
		}
     	return 1;
    }
    if(!strcmp(cmdtext, "/water"))
	{
	    if(PlayerInfo[playerid][HouseKey]==0) { return 1; }
	    if(GetPlayerVirtualWorld(playerid)!=PlayerInfo[playerid][HouseKey]) { SendClientMessage(playerid, COLOR_LIGHTRED, "You aren't at home."); return 1; }
	    new key = PlayerInfo[playerid][HouseKey];
	    if(PlayerToPoint(1.5, playerid, House[key][Seedx], House[key][Seedy], House[key][Seedz]))
	    {
	        if(House[key][Seed]!=2) { SendClientMessage(playerid, COLOR_LIGHTRED, "Water is not necessary, drink it if you want."); return 1; }
	        if(PlayerInfo[playerid][Hand]!=31) { SendClientMessage(playerid, COLOR_LIGHTRED, "You don't have water."); return 1; }
	        SendClientMessage(playerid, COLOR_YELLOW, "* You have watered it successfully.");
		    SendClientMessage(playerid, COLOR_GREEN, "You should check your /plant from time to time.");
			PlayerInfo[playerid][Hand]=0;
			PlayerInfo[playerid][HandAmount]=0;
			RemovePlayerAttachedObject(playerid, 0);
			LoopingAnim(playerid, "CARRY", "putdwn105",4.1,0,0,0,0,0);
			House[key][Seed]=3;
   		}
	    else
	    {
     		SendClientMessage(playerid, COLOR_LIGHTRED, "Seemingly you're not close to your plant.");
	    }
		return 1;
	}
	if(!strcmp(cmdtext, "/plant"))
	{
	    if(PlayerInfo[playerid][HouseKey]==0) { return 1; }
	    if(GetPlayerVirtualWorld(playerid)!=PlayerInfo[playerid][HouseKey]) { SendClientMessage(playerid, COLOR_LIGHTRED, "You aren't at home."); return 1; }
	    new key = PlayerInfo[playerid][HouseKey];
	    if(PlayerToPoint(1.5, playerid, House[key][Seedx], House[key][Seedy], House[key][Seedz]))
	    {
	        if(House[key][Seed]<3) { return 1; }
	        if(House[key][Seed]==20)
	        {
	            SendClientMessage(playerid, COLOR_YELLOW, "* You check your plant and and there are enough sprouts to do the harvest.");
		    	format(string, sizeof(string),"Sprouts: %d (/makebundle)",House[key][Seed]);
				SendClientMessage(playerid, COLOR_GREEN, string);
	        }
	        else
	        {
	            SendClientMessage(playerid, COLOR_RED, "* You check your plant and there are not enough sprouts to do the harvest. Wait a day.");
		    	format(string, sizeof(string),"Sprouts: %d",House[key][Seed]);
				SendClientMessage(playerid, COLOR_GREEN, string);
	        }
	    }
	    else
	    {
     		SendClientMessage(playerid, COLOR_LIGHTRED, "Seemingly you're not close to your plant.");
	    }
		return 1;
	}
	if(!strcmp(cmdtext, "/makebundle"))
	{
	    if(PlayerInfo[playerid][HouseKey]==0) { return 1; }
	    if(GetPlayerVirtualWorld(playerid)!=PlayerInfo[playerid][HouseKey]) { SendClientMessage(playerid, COLOR_LIGHTRED, "You aren't at home."); return 1; }
	    new key = PlayerInfo[playerid][HouseKey];
	    if(PlayerToPoint(1.5, playerid, House[key][Seedx], House[key][Seedy], House[key][Seedz]))
	    {
	        if(House[key][Seed]!=20) { return 1; }
	        if(PlayerInfo[playerid][Hand]!=0) { SendClientMessage(playerid, COLOR_LIGHTRED, "Your hands are busy."); return 1; }
	        PlayerInfo[playerid][Hand]=45;
  			PlayerInfo[playerid][HandAmount]=20;
  			ResetObject(playerid);
  			House[key][Seed]=3;
	    }
	    else
	    {
     		SendClientMessage(playerid, COLOR_LIGHTRED, "Seemingly you're not close to your marijuana plant.");
	    }
		return 1;
	}
	if(!strcmp(cmdtext, "/closet"))
	{
	    if(PlayerInfo[playerid][HouseKey]==0) { return 1; }
	    if(GetPlayerVirtualWorld(playerid)!=PlayerInfo[playerid][HouseKey]) { SendClientMessage(playerid, COLOR_LIGHTRED, "You aren't at home."); return 1; }
	    new key = PlayerInfo[playerid][HouseKey];
	    if(PlayerToPoint(30.0, playerid, House[key][Exitx], House[key][Exity], House[key][Exitz]))
	    {
	        if(PlayerInfo[playerid][Hand]!=0) { SendClientMessage(playerid, COLOR_LIGHTRED, "Your hands are busy."); return 1; }
	        new cantidad1 = House[key][Amount1];
	        new cantidad2 = House[key][Amount2];
	        new cantidad3 = House[key][Amount3];
	        format(string,sizeof(string),"%s (%d)\n%s (%d)\n%s (%d)",Obje[House[key][Closet1]],cantidad1,Obje[House[key][Closet2]],cantidad2,Obje[House[key][Closet3]],cantidad3);
        	ShowPlayerDialog(playerid,14,DIALOG_STYLE_LIST,"Closet",string,"Take","No");
	    }
	    else
	    {
     		SendClientMessage(playerid, COLOR_LIGHTRED, "Seemingly you are not at home.");
	    }
		return 1;
	}
	if(!strcmp(cmdtext, "/putincloset"))
	{
	    if(PlayerInfo[playerid][HouseKey] == 0) { return 1; }
	    if(GetPlayerVirtualWorld(playerid) != PlayerInfo[playerid][HouseKey]) { return 1; }
	    new key = PlayerInfo[playerid][HouseKey];
	    if(!PlayerToPoint(30.0, playerid, House[key][Exitx], House[key][Exity], House[key][Exitz]))
	    {
	        SendClientMessage(playerid, COLOR_LIGHTRED, "Seemingly you are not at home.");
	        return 1;
		}
  		if(PlayerInfo[playerid][Hand] == 0) { return 1; }
        new gunAmmo = GetPlayerAmmo(playerid);
        new cantidad;
        if(0 < PlayerInfo[playerid][Hand] < 14) { cantidad = gunAmmo; }
		else { cantidad = PlayerInfo[playerid][HandAmount]; }
        new mierda[3] = {0,0,0};
        mierda[0] = House[key][Closet1]; mierda[1] = House[key][Closet2]; mierda[2] = House[key][Closet3];
        for(new i = 0; i < 3; i++)
        {
            if(mierda[i] == 0)
            {
	 			if(i == 0) { House[key][Closet1] = PlayerInfo[playerid][Hand]; House[key][Amount1] = cantidad; }
	 			else if(i == 1) { House[key][Closet2] = PlayerInfo[playerid][Hand]; House[key][Amount2] = cantidad; }
	 			else if(i == 2) { House[key][Closet3] = PlayerInfo[playerid][Hand]; House[key][Amount3] = cantidad; }
	 			RemovePlayerAttachedObject(playerid, 0);
 				ResetPlayerWeapons(playerid);
		 		CarryingBox[playerid]=0;
		 		PlayerInfo[playerid][Hand]=0;
		 		PlayerInfo[playerid][HandAmount]=0;
		  		format(string, sizeof(string), "* %s puts something in the closet.", NombreEx(playerid));
		    	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		    	return 1;
            }
        }
        SendClientMessage(playerid, COLOR_LIGHTRED, "The closet is full.");
		return 1;
	}
	if(!strcmp(cmd, "/sit"))
	{
		new animid;
		tmp = strtok(cmdtext, idx);
		animid = strval(tmp);
		if(!strlen(tmp) ||animid < 1 || animid > 4)
			{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /sit [1-4]");
			return 1;
		}
		switch(animid)
		{
			case 1: LoopingAnim(playerid, "ped", "SEAT_down", 4.000000, 0, 0, 0, 1, 0);
			case 2: LoopingAnim(playerid,"Attractors","Stepsit_in",4.1,0,0,0,1,0);
			case 3: LoopingAnim(playerid, "SUNBATHE", "ParkSit_M_in", 4.000000, 0, 1, 1, 1, 0);
			case 4: LoopingAnim(playerid,"INT_HOUSE","LOU_In",4.1,0,1,1,1,1);
		}
		return 1;
    }
	if(!strcmp(cmd, "/takeunitfromcloset"))
	{
		new slot;
		tmp = strtok(cmdtext, idx);
		slot = strval(tmp);
		if(!strlen(tmp) || slot < 1 || slot > 3)
			{
			SendClientMessage(playerid,COLOR_WHITE," Usage: /takeunitfromcloset [1-4]");
			return 1;
		}
		if(PlayerInfo[playerid][HouseKey] == 0) { return 1; }
    	if(GetPlayerVirtualWorld(playerid)!=PlayerInfo[playerid][HouseKey]) { return 1; }
    	new key = PlayerInfo[playerid][HouseKey];
    	if(!PlayerToPoint(30.0, playerid, House[key][Exitx], House[key][Exity], House[key][Exitz]))
    	{
    	    SendClientMessage(playerid, COLOR_LIGHTRED, "Seemingly you are not at home.");
    		return 1;
  		}
  		// box, weapon, bullets
  		new combination[][] = {
  		    {40, 1, 17},
  		    {41, 6, 50},
  		    {42, 18, 17},
  		    {43, 23, 50},
  		    {44, 25, 30},
  		    {45, 48, 5},
  		    {46, 49, 1}
  		};
  		switch(slot)
  		{
  		    case 1:
		  	{
				for(new i = 0; i < sizeof(combination); i++)
				{
				    if(House[key][Closet1] == combination[i][0])
				    {
				        PlayerInfo[playerid][Hand] = combination[i][1];
				        PlayerInfo[playerid][HandAmount] = combination[i][2];
				    }
				}
			}
  		    case 2:
  		    {
				for(new i = 0; i < sizeof(combination); i++)
				{
				    if(House[key][Closet2] == combination[i][0])
				    {
				        PlayerInfo[playerid][Hand] = combination[i][1];
				        PlayerInfo[playerid][HandAmount] = combination[i][2];
				    }
				}
			}
  		    case 3:
            {
				for(new i = 0; i < sizeof(combination); i++)
				{
				    if(House[key][Closet3] == combination[i][0])
				    {
				        PlayerInfo[playerid][Hand] = combination[i][1];
				        PlayerInfo[playerid][HandAmount] = combination[i][2];
				    }
				}
			}
  		}
  		if(House[key][Amount1] < 1) { House[key][Closet1] = 0; }
  		if(House[key][Amount2] < 1) { House[key][Closet2] = 0; }
  		if(House[key][Amount3] < 1) { House[key][Closet3] = 0; }
		ResetObject(playerid);
	    return 1;
	}
	if(!strcmp(cmd, "/me"))
	{
		new length = strlen(cmdtext);
		while ((idx < length) && (cmdtext[idx] <= ' '))
		{
			idx++;
		}
		new offset = idx;
		new result[128];
		while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
		{
			result[idx - offset] = cmdtext[idx];
			idx++;
		}
		result[idx - offset] = EOS;
		if(!strlen(result))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /me [action of your character]");
			return 1;
		}
		if(Masked[playerid] == 1)
		{
		    format(string, sizeof(string), "Stranger %s", result);
		}
		else
		{
			format(string, sizeof(string), "%s %s", NombreEx(playerid), result);
		}
		ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		printf("%s", string);
		return 1;
	}
	if(!strcmp(cmd, "/do"))
	{
		new length = strlen(cmdtext);
		while ((idx < length) && (cmdtext[idx] <= ' '))
		{
			idx++;
		}
		new offset = idx;
		new result[128];
		while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
		{
			result[idx - offset] = cmdtext[idx];
			idx++;
		}
		result[idx - offset] = EOS;
		if(!strlen(result))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /do [environment/explanation]");
			return 1;
		}
		if(Masked[playerid] == 1)
		{
		    format(string, sizeof(string), "[Stranger] %s ",result);
		}
		else
		{
			format(string, sizeof(string), "[ID: %i] %s",playerid,result);
		}
		ProxDetector(30.0, playerid, string, COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN);
		printf("%s", string);
		return 1;
	}
	if(!strcmp(cmd, "/try"))
	{
		new length = strlen(cmdtext);
		while ((idx < length) && (cmdtext[idx] <= ' '))
		{
			idx++;
		}
		new offset = idx;
		new result[128];
		while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
		{
			result[idx - offset] = cmdtext[idx];
			idx++;
		}
		result[idx - offset] = EOS;
		if(!strlen(result))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /try [action]");
			SendClientMessage(playerid, COLOR_GREY, "(( You have a fifty percent of success, don't use this command against other players )).");
			return 1;
		}
		new Logra;
	 	Logra = random(2);
	  	switch(Logra)
	  	{
			case 0:
			{
			    format(string, sizeof(string), "* %s tries to %s but fails.", NombreEx(playerid), result);
			}
			case 1:
			{
			    format(string, sizeof(string), "* %s tries to %s successfully.", NombreEx(playerid), result);
			}
	   	}
		ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		printf("%s", string);
		return 1;
	}
	if(!strcmp(cmdtext, "/description"))
	{
	    if(TActivado[playerid] == 1)
	    {
	        SendClientMessage(playerid, 0xCBCCCEFF, "(( First you should use /removedescription )).");
	        return 1;
		}
		new length = strlen(cmdtext);
		while ((idx < length) && (cmdtext[idx] <= ' '))
		{
			idx++;
		}
		new offset = idx;
		new result[64];
		while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
		{
			result[idx - offset] = cmdtext[idx];
			idx++;
		}
		result[idx - offset] = EOS;
		if(!strlen(result))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /description [additional information, shown above your character to other players]");
			if(TActivado[playerid] == 1)
	        {
		        format(string, sizeof(string), "(( Your description is: %s )).",result);
				SendClientMessage(playerid, COLOR_LIGHTRED, string);
	        }
			return 1;
		}
	    format(string, sizeof(string), "{EE5555} %s",result);
	    LOL[playerid] = Create3DTextLabel(string,0x85C051FF,30.0,40.0,5.0,40.0,1);
		Attach3DTextLabelToPlayer(LOL[playerid], playerid, 0.0, 0.0, 0.40);
		format(string, sizeof(string), "(( Your new description is: %s )).",result);
		SendClientMessage(playerid, COLOR_LIGHTRED, string);
		TActivado[playerid] = 1;
		return 1;
	}
	if(!strcmp("/removedescription", cmdtext))
	{
		if(TActivado[playerid] == 1)
        {
		    TActivado[playerid] = 0;
		    SendClientMessage(playerid, COLOR_GREY, "(( Description removed )).");
		    Delete3DTextLabel(LOL[playerid]);
		    return 1;
		}
		return SendClientMessage(playerid, 0xCBCCCEFF, "(( Your description was already non-existent )).");
	}
	if(!strcmp(cmd, "/b"))
	{
		new length = strlen(cmdtext);
		while ((idx < length) && (cmdtext[idx] <= ' '))
		{
			idx++;
		}
		new offset = idx;
		new result[128];
		while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
		{
			result[idx - offset] = cmdtext[idx];
			idx++;
		}
		result[idx - offset] = EOS;
		if(!strlen(result))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /b [OOC message]");
			return 1;
		}
		format(string, sizeof(string), "(( [%i] %s: %s ))", playerid, NombreEx(playerid), result);
		ProxDetector(20.0, playerid, string,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
		printf("%s", string);
		return 1;
	}
	if(!strcmp(cmd, "/whisper"))
	{
		new length = strlen(cmdtext);
		while ((idx < length) && (cmdtext[idx] <= ' '))
		{
			idx++;
		}
		new offset = idx;
		new result[128];
		while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
		{
			result[idx - offset] = cmdtext[idx];
			idx++;
		}
		result[idx - offset] = EOS;
		if(!strlen(result))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /whisper [message]");
			return 1;
		}
		if(Masked[playerid] == 1)
		{
			format(string, sizeof(string), "Stranger whispers: %s", result);
		}
		else
		{
			format(string, sizeof(string), "%s whispers: %s", NombreEx(playerid), result);
		}
		ProxDetector(3.0, playerid, string,COLOR_WHITE,COLOR_WHITE,COLOR_WHITE,COLOR_FADE1,COLOR_FADE2);
		printf("%s", string);
		return 1;
	}
	if(!strcmp(cmd, "/shout"))
	{
		new length = strlen(cmdtext);
		while ((idx < length) && (cmdtext[idx] <= ' '))
		{
			idx++;
		}
		new offset = idx;
		new result[128];
		while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
		{
			result[idx - offset] = cmdtext[idx];
			idx++;
		}
		result[idx - offset] = EOS;
		if(!strlen(result))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /shout [text]");
			return 1;
		}
		if(Masked[playerid] == 1)
		{
			format(string, sizeof(string), "Stranger shouts: %s!", result);
		}
		else
		{
			format(string, sizeof(string), "%s shouts: %s!", NombreEx(playerid), result);
		}
		ProxDetector(50.0, playerid, string,COLOR_WHITE,COLOR_WHITE,COLOR_WHITE,COLOR_FADE1,COLOR_FADE2);
		printf("%s", string);
		return 1;
	}
	if(!strcmp(cmdtext, "/animations"))
	{
        SendClientMessage(playerid, COLOR_LIGHTRED,"__| List of animations in Homeless World - Role Play |__");
        SendClientMessage(playerid, COLOR_WHITE,"/sit  /liedown  /walk  /greet  /laugh");
	    SendClientMessage(playerid, COLOR_WHITE,"/listen  /kiss  /pool");
	    SendClientMessage(playerid, COLOR_WHITE,"/smoke  /negotiate  /crosshands  /crossarms  /rest");
	    SendClientMessage(playerid, COLOR_WHITE,"/dare  /walkgangster  /rap  /bat");
	    SendClientMessage(playerid, COLOR_WHITE,"/giveup  /headup  /headdown");
	    SendClientMessage(playerid, COLOR_WHITE,"/traffic  /point  /bomb  /spray  /medic");
	    SendClientMessage(playerid, 0xCBCCCEFF, "(( To end an animation, you can use the key SPACE BAR )).");
		return 1;
	}
	if(!strcmp(cmd, "/sit"))
	{
		new animid;
		tmp = strtok(cmdtext, idx);
		animid = strval(tmp);
		if(!strlen(tmp)||animid < 1 || animid > 4)
			{
			SendClientMessage(playerid,COLOR_WHITE," Usage: /sit [1-4]");
			return 1;
		}
		switch(animid)
		{
			case 1: LoopingAnim(playerid, "ped", "SEAT_down", 4.000000, 0, 0, 0, 1, 0);
			case 2: LoopingAnim(playerid,"Attractors","Stepsit_in",4.1,0,0,0,1,0);
			case 3: LoopingAnim(playerid, "SUNBATHE", "ParkSit_M_in", 4.000000, 0, 1, 1, 1, 0);
			case 4: LoopingAnim(playerid,"INT_HOUSE","LOU_In",4.1,0,1,1,1,1);
		}
		return 1;
    }
    if(!strcmp(cmdtext, "/listen")) {
		 LoopingAnim(playerid, "BAR", "Barserve_order",4.1,0,0,0,0,0);
         return 1;
    }
    if(!strcmp("/laugh", cmdtext)) {
       LoopingAnim(playerid, "RAPPING", "Laugh_01", 4.1,0,0,0,0,0);
       return 1;
    }
    if(!strcmp(cmdtext, "/dare")) {
		LoopingAnim(playerid,"RIOT","RIOT_ANGRY",4.1,0,0,0,0,0);
        return 1;
    }
    if(!strcmp(cmdtext, "/medic")) {
		 LoopingAnim(playerid,"MEDIC","CPR",4.1,0,0,0,0,0);
         return 1;
    }
    if(!strcmp(cmdtext, "/bomb")) {
		 LoopingAnim(playerid,"BOMBER","BOM_Plant",4.1,0,0,0,0,0);
         return 1;
    }
    if(!strcmp(cmdtext, "/spray")) {
		 LoopingAnim(playerid,"SPRAYCAN","spraycan_full",4.1,0,0,0,0,0);
         return 1;
    }
    if(!strcmp(cmdtext, "/smoke")) {
		 LoopingAnim(playerid,"SMOKING","M_smk_in",4.0,0,1,1,1,1);
         return 1;
    }
    if(!strcmp(cmdtext, "/giveup")) {
		LoopingAnim(playerid, "ROB_BANK","SHP_HandsUp_Scr", 4.1,0,1,1,1,1);
        return 1;
    }
    if(!strcmp("/negotiate", cmdtext)) {
          LoopingAnim(playerid, "DEALER", "DEALER_DEAL", 4.1,0,0,0,0,0);
		  return 1;
	}
    if(!strcmp(cmdtext, "/headup")) {
		 LoopingAnim(playerid,"PED","KO_skid_front",4.1,0,1,1,1,1);
         return 1;
    }
    if(!strcmp(cmdtext, "/headdown")) {
		 LoopingAnim(playerid, "PED","FLOOR_hit_f", 4.1,0,1,1,1,1);
         return 1;
    }
	if(!strcmp(cmdtext, "/crosshands")) {
		 LoopingAnim(playerid,"DEALER","DEALER_IDLE",4.1,0,1,1,1,1);
         return 1;
    }
    if(!strcmp(cmdtext, "/crossarms"))
	{
		LoopingAnim(playerid, "COP_AMBIENT", "Coplook_loop",4.1,0,1,1,1,1);
  		return 1;
    }
    if(!strcmp(cmd, "/bat"))
	{
		new animid;
		tmp = strtok(cmdtext, idx);
		animid = strval(tmp);
		if(!strlen(tmp)||animid < 1 || animid > 2)
		{
			SendClientMessage(playerid,COLOR_WHITE," Usage: /bat [1-2]");
			return 1;
		}
		switch(animid)
		{
			case 1: LoopingAnim(playerid,"CRACK","Bbalbat_Idle_01",4.1,0,1,1,1,1);
			case 2: LoopingAnim(playerid,"CRACK","Bbalbat_Idle_02",4.1,0,1,1,1,1);
		}
		return 1;
	}
	if(!strcmp(cmd, "/walkgangster"))
	{
		new animid;
		tmp = strtok(cmdtext, idx);
		animid = strval(tmp);
		if(!strlen(tmp)||animid < 1 || animid > 2)
		{
			SendClientMessage(playerid,COLOR_WHITE," Usage: /walkgangster [1-2]");
			return 1;
		}
		switch(animid)
		{
			case 1: LoopingAnim(playerid,"PED","WALK_gang1",4.0,1,1,1,1,500);
			case 2: LoopingAnim(playerid,"PED","WALK_gang2",4.0,1,1,1,1,500);
		}
		return 1;
	}
	if(!strcmp(cmd, "/rap"))
	{
		new animid;
		tmp = strtok(cmdtext, idx);
		animid = strval(tmp);
		if(!strlen(tmp)||animid < 1 || animid > 3)
		{
			SendClientMessage(playerid,COLOR_WHITE," Usage: /rap [1-3]");
			return 1;
		}
		switch(animid)
		{
			case 1: LoopingAnim(playerid, "RAPPING", "RAP_A_Loop", 4.1, 1, 1, 1, 1, 1);
			case 2: LoopingAnim(playerid, "RAPPING", "RAP_B_Loop", 4.1, 1, 1, 1, 1, 1);
			case 3: LoopingAnim(playerid, "RAPPING", "RAP_C_Loop", 4.1, 1, 1, 1, 1, 1);
		}
		return 1;
	}
	if(!strcmp(cmd, "/liedown"))
	{
		new animid;
		tmp = strtok(cmdtext, idx);
		animid = strval(tmp);
		if(!strlen(tmp)||animid < 1 || animid > 2)
		{
			SendClientMessage(playerid,COLOR_WHITE," Usage: /liedown [1-2]");
			return 1;
		}
		switch(animid)
		{
			case 1: LoopingAnim(playerid,"INT_HOUSE","BED_In_R",4.1,0,0,0,1,0);
			case 2: LoopingAnim(playerid,"SUNBATHE", "Lay_Bac_in", 4.0, 0, 0, 0, 1, 0);
		}
		return 1;
	}
 	if(!strcmp(cmd, "/walk"))
	{
		new animid;
		tmp = strtok(cmdtext, idx);
		animid = strval(tmp);
		if(!strlen(tmp)||animid < 1 || animid > 9)
		{
			SendClientMessage(playerid,0xEFEFF7AA," Usage: /walk [1-9]");
			return 1;
		}
		switch(animid)
		{
	     	case 1: LoopingAnim(playerid,"FAT","FatWalk",4.1,1,1,1,1,1);
			case 2: LoopingAnim(playerid,"PED","WALK_civi",4.1,1,1,1,1,1);
			case 3: LoopingAnim(playerid,"PED","WALK_old",4.1,1,1,1,1,1);
			case 4: LoopingAnim(playerid,"PED","WALK_player",4.1,1,1,1,1,1);
			case 5: LoopingAnim(playerid,"PED","WOMAN_walkbusy",4.1,1,1,1,1,1);
			case 6: LoopingAnim(playerid,"PED","WOMAN_walknorm",4.1,1,1,1,1,1);
			case 7: LoopingAnim(playerid,"PED","WOMAN_walkpro",4.1,1,1,1,1,1);
			case 8: LoopingAnim(playerid,"PED","WOMAN_walksexy",4.1,1,1,1,1,1);
			case 9: LoopingAnim(playerid,"POOL","POOL_Walk",4.1,1,1,1,1,1);
		}
		return 1;
	}
	if(!strcmp(cmd, "/traffic"))
	{
		new animid;
		tmp = strtok(cmdtext, idx);
		animid = strval(tmp);
		if(!strlen(tmp)||animid < 1 || animid > 4)
			{
			SendClientMessage(playerid,0xEFEFF7AA," Usage: /traffic [1-4]");
			return 1;
		}
		switch(animid)
		{
			case 1: LoopingAnim(playerid,"POLICE","CopTraf_Away",4.1,1,0,0,1,1);
			case 2: LoopingAnim(playerid,"POLICE","CopTraf_Come",4.1,1,0,0,1,1);
			case 3: LoopingAnim(playerid,"POLICE","CopTraf_Left",4.1,1,0,0,1,1);
			case 4: LoopingAnim(playerid,"POLICE","CopTraf_Stop",4.1,1,0,0,1,1);
		}
		return 1;
	}
    if(!strcmp(cmd, "/point"))
    {
        if (!strlen(cmdtext[7])) return SendClientMessage(playerid,0xEFEFF7AA,"Usage: /point [1-3]");
    	switch (cmdtext[7])
    	{
        	case '1': LoopingAnim(playerid,"SHOP","ROB_Loop_Threat",4.1,1,0,0,1,1);
        	case '2': LoopingAnim(playerid,"ped", "ARRESTgun", 4.0,0,1,1,1,1);
        	case '3': LoopingAnim(playerid,"SHOP","SHP_Gun_Aim",4.1,1,0,0,1,1);
        	default: SendClientMessage(playerid,0xEFEFF7AA,"Usage: /point [1-3]");
    	}
    	return 1;
    }
    if(!strcmp(cmd, "/rest"))
    {
        if (!strlen(cmdtext[6])) return SendClientMessage(playerid,0xEFEFF7AA,"Usage: /rest [1-2]");
    	switch (cmdtext[6])
    	{
        	case '1': LoopingAnim(playerid,"GANGS","leanIDLE",4.0,1,0,1,1,1);
        	case '2': LoopingAnim(playerid,"MISC","Plyrlean_loop",4.0,1,1,1,1,1);
        	default: SendClientMessage(playerid,0xEFEFF7AA,"Usage: /rest [1-2]");
    	}
    	return 1;
    }
    if(!strcmp(cmd, "/kiss"))
    {
        if (!strlen(cmdtext[6])) return SendClientMessage(playerid,0xEFEFF7AA,"Usage: /kiss [1-2]");
    	switch (cmdtext[6])
    	{
        	case '1': LoopingAnim(playerid,"KISSING","Grlfrd_Kiss_03",4.1,0,0,0,1,1);
        	case '2': LoopingAnim(playerid,"KISSING","Playa_Kiss_03",4.1,0,0,0,1,1);
        	default: SendClientMessage(playerid,0xEFEFF7AA,"Usage: /kiss [1-2]");
    	}
    	return 1;
    }
    if(!strcmp(cmd, "/pool"))
    {
        if (!strlen(cmdtext[6])) return SendClientMessage(playerid,0xEFEFF7AA,"Usage: /pool [1-3]");
    	switch (cmdtext[6])
    	{
        	case '1': LoopingAnim(playerid,"POOL","POOL_Idle_Stance",4.1,0,1,1,1,1);
        	case '2': LoopingAnim(playerid,"POOL","POOL_Med_Start",4.1,0,1,1,1,1);
        	case '3': LoopingAnim(playerid,"POOL","POOL_Med_Shot",4.1,0,1,1,1,1);
        	default: SendClientMessage(playerid,0xEFEFF7AA,"Usage: /pool [1-3]");
    	}
    	return 1;
    }
    if(!strcmp(cmd, "/greet"))
    {
        if (!strlen(cmdtext[7])) return SendClientMessage(playerid,COLOR_WHITE,"Usage: /greet [1-7]");
    	switch (cmdtext[7])
    	{
        	case '1': LoopingAnim(playerid,"GANGS","prtial_hndshk_biz_01",4.1,0,1,1,1,1);
        	case '2': LoopingAnim(playerid,"GANGS","hndshkcb",4.1,0,1,1,1,1);
        	case '3': LoopingAnim(playerid,"GANGS","hndshkea",4.1,0,1,1,1,1);
        	case '4': LoopingAnim(playerid,"GANGS","hndshkfa",4.1,0,1,1,1,1);
        	case '5': LoopingAnim(playerid,"GANGS","hndshkba",4.1,0,1,1,1,1);
        	case '6': LoopingAnim(playerid,"ON_LOOKERS", "wave_loop", 4.0, 1, 0, 0, 1, 1);
        	case '7': LoopingAnim(playerid,"PED","endchat_03",4.1,0,1,1,1,1);
			default: SendClientMessage(playerid,COLOR_WHITE,"Usage: /greet [1-7]");
    	}
    	return 1;
    }
	if(!strcmp(cmd, "/putcone"))
 	{
		if(PlayerInfo[playerid][Faction] == 1 || PlayerInfo[playerid][Faction] == 2)
  		{
			new Float:plocx,Float:plocy,Float:plocz,Float:ploca;
 			GetPlayerPos(playerid, plocx, plocy, plocz);
 			GetPlayerFacingAngle(playerid,ploca);
 			CreateCono(plocx,plocy,plocz,ploca);
			return 1;
		}
		return 1;
	}
	if(!strcmp(cmd, "/removecone"))
 	{
		if(PlayerInfo[playerid][Faction] == 1 || PlayerInfo[playerid][Faction] == 2)
		{
 			DeleteClosestCono(playerid);
			return 1;
 		}
		return 1;
	}
	if(!strcmp(cmdtext, "/removecones"))
 	{
		if(PlayerInfo[playerid][Faction] == 1 || PlayerInfo[playerid][Faction] == 2)
		{
 			DeleteAllConos();
 			SendClientMessage(playerid, COLOR_BLUE, "* You removed all LSPD/LSMD cones.");
			return 1;
		}
		return 1;
	}
	if(!strcmp(cmdtext, "/putfence"))
 	{
		if(PlayerInfo[playerid][Faction] == 1 || PlayerInfo[playerid][Faction] == 2)
		{
			new Float:plocx,Float:plocy,Float:plocz,Float:ploca;
 			GetPlayerPos(playerid, plocx, plocy, plocz);
 			GetPlayerFacingAngle(playerid,ploca);
 			CreateValla(plocx,plocy,plocz,ploca);
			return 1;
 		}
		return 1;
	}
	if(!strcmp(cmdtext, "/removefence"))
 	{
		if(PlayerInfo[playerid][Faction] == 1 || PlayerInfo[playerid][Faction] == 2)
		{
 			DeleteClosestValla(playerid);
			return 1;
 		}
		return 1;
 	}
 	if(!strcmp(cmd, "/r") || !strcmp(cmd, "/radio"))
	{
        if(PlayerInfo[playerid][Faction] == 1)
		{
			new length = strlen(cmdtext);
			while ((idx < length) && (cmdtext[idx] <= ' '))
			{
				idx++;
			}
			new offset = idx;
			new result[128];
			while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
			{
				result[idx - offset] = cmdtext[idx];
				idx++;
			}
			result[idx - offset] = EOS;
			if(!strlen(result))
			{
				SendClientMessage(playerid, COLOR_GREY, "Usage: (/r)adio [message]");
				return 1;
			}
			new Float:x, Float:y, Float:z;
			GetPlayerPos(playerid,x,y,z);
			for(new i = 0; i < MAX_PLAYERS; i++)
			{
				    if(PlayerToPoint(10, i, x, y, z))
				    {
						if(PlayerInfo[i][Faction] != 1)
						{
				    		format(string, sizeof(string), "[RADIO] %s says: %s", NombreEx(playerid), result);
				    		SendClientMessage(i, COLOR_FADE3, string);
						}
					}
			}
			format(string, sizeof(string), "[RADIO] %s: %s", NombreEx(playerid), result);
            SendFamilyMessage(1, COLOR_BLUE, string);
            printf("%s", string);
		}
		else if(PlayerInfo[playerid][Faction] == 2)
		{
			new length = strlen(cmdtext);
			while ((idx < length) && (cmdtext[idx] <= ' '))
			{
				idx++;
			}
			new offset = idx;
			new result[128];
			while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
			{
				result[idx - offset] = cmdtext[idx];
				idx++;
			}
			result[idx - offset] = EOS;
			if(!strlen(result))
			{
				SendClientMessage(playerid, COLOR_GREY, "Usage: (/r)adio [message]");
				return 1;
			}
			new Float:x, Float:y, Float:z;
			GetPlayerPos(playerid,x,y,z);
			for(new i = 0; i < MAX_PLAYERS; i++)
			{
				    if(PlayerToPoint(10, i, x, y, z))
				    {
                      	if(PlayerInfo[i][Faction] != 2)
						{
				    		format(string, sizeof(string), "[RADIO] %s says: %s", NombreEx(playerid), result);
				    		SendClientMessage(i, COLOR_FADE3, string);
						}
					}
			}
			format(string, sizeof(string), "[RADIO] %s: %s", NombreEx(playerid), result);
            SendFamilyMessage(2, COLOR_BLUE, string);
            printf("%s", string);
		}
		else if(PlayerInfo[playerid][Faction] == 3)
		{
			new length = strlen(cmdtext);
			while ((idx < length) && (cmdtext[idx] <= ' '))
			{
				idx++;
			}
			new offset = idx;
			new result[128];
			while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
			{
				result[idx - offset] = cmdtext[idx];
				idx++;
			}
			result[idx - offset] = EOS;
			if(!strlen(result))
			{
				SendClientMessage(playerid, COLOR_GREY, "Usage: (/r)adio [message]");
				return 1;
			}
			new Float:x, Float:y, Float:z;
			GetPlayerPos(playerid,x,y,z);
			for(new i = 0; i < MAX_PLAYERS; i++)
			{
				    if(PlayerToPoint(10, i, x, y, z))
				    {
                      	if(PlayerInfo[i][Faction] != 3)
						{
				    		format(string, sizeof(string), "[RADIO] %s says: %s", NombreEx(playerid), result);
				    		SendClientMessage(i, COLOR_FADE3, string);
						}
					}
			}
			format(string, sizeof(string), "[RADIO] %s: %s", NombreEx(playerid), result);
            SendFamilyMessage(3, COLOR_BLUE, string);
            printf("%s", string);
		}
		else
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED, "You don't have a walkie-talkie.");
		}
		return 1;
	}
	if(!strcmp(cmd, "/megaphone") || !strcmp(cmd, "/m"))
	{
		GetPlayerName(playerid, sendername, sizeof(sendername));
		new length = strlen(cmdtext);
		while ((idx < length) && (cmdtext[idx] <= ' '))
		{
			idx++;
		}
		new offset = idx;
		new result[128];
		while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
		{
			result[idx - offset] = cmdtext[idx];
			idx++;
		}
		result[idx - offset] = EOS;
		if(!strlen(result))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: (/m)egaphone [warning to citizens]");
			return 1;
		}
		if(PlayerInfo[playerid][Faction] == 1)
		{
			if(IsPlayerInAnyVehicle(playerid))
			{
				format(string, sizeof(string), "[MEGAPHONE]: %s", result);
				ProxDetector(60.0, playerid, string,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
				printf("%s", string);
			}
			else
			{
			    SendClientMessage(playerid, COLOR_GREY, "You are not in a vehicle.");
			    return 1;
			}
		}
		return 1;
	}
 	if(!strcmp("/open", cmdtext))
	{
	    if(PlayerInfo[playerid][Faction] == 1)
		{
		    if(PlayerToPoint(10.5,playerid,1544.7,-1630.8,13))
		    {
        		MoveDynamicObject(lspdexterior, 1544.7, -1630.8, 13.1+0.0001, 0.0001, 0, 0, 90);
        		return 1;
			}
			else if(PlayerToPoint(5,playerid,244.9, 72.57, 1002.6))
			{
      			MoveDynamicObject(lspddoor1, 243.9,72.569,1002.599, 3.5000);
      			MoveDynamicObject(lspddoor2, 248.9,72.599,1002.599, 3.5000);
      			return 1;
			}
			else if(PlayerToPoint(3,playerid,1799.2998,-1546.7002,-12.3))
			{
			    MoveDynamicObject(prisondoor,1799.2998,-1546.7002,-9.3, 0.5);
			    GetPlayerName(playerid, sendername, sizeof(sendername));
	        	format(string, sizeof(string), "* %s opens the door of the prison.", sendername);
      			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			}
		}
		return 1;
	}
	if(!strcmp("/close", cmdtext))
	{
	    if(PlayerInfo[playerid][Faction] == 1)
		{
		    if(PlayerToPoint(10.5,playerid,1544.7,-1630.8,13))
		    {
        		MoveDynamicObject(lspdexterior, 1544.7, -1630.8, 13.1-0.0001, 0.0001, 0, 90, 90);
        		return 1;
        	}
        	else if(PlayerToPoint(5,playerid,244.9, 72.57, 1002.6))
			{
      			MoveDynamicObject(lspddoor1, 244.88999938965, 72.569999694824, 1002.5999755859,3);
      			MoveDynamicObject(lspddoor2, 247.89999389648, 72.599998474121, 1002.5999755859,3);
      			return 1;
			}
			else if(PlayerToPoint(3,playerid,1799.2998,-1546.7002,-12.3))
			{
			    MoveDynamicObject(prisondoor,1799.2998,-1546.7002,-12.3, 0.5);
			}
        }
		return 1;
	}
	if(!strcmp(cmdtext, "/rooftop"))
	{
	    if(PlayerToPoint(2,playerid,246.4406,87.4276,1003.6406))
	    {
	    	SetPlayerPos(playerid,1564.7402,-1666.0062,28.3956);
	    	SetPlayerInterior(playerid,0);
	    }
	    else if(PlayerToPoint(2,playerid,1926.3743,-1509.0028,499.1879))
	    {
	    	SetPlayerPos(playerid,1163.2063,-1329.7548,31.4863);
	    	SetPlayerInterior(playerid,0);
	    }
		return 1;
	}
	if(!strcmp(cmd, "/invite"))
	{
		if(PlayerInfo[playerid][Faction] == 0) return 1;
		if(PlayerInfo[playerid][Faction] == 1 && PlayerInfo[playerid][Rank] < 5) return 1;
		if(PlayerInfo[playerid][Faction] == 2 && PlayerInfo[playerid][Rank] < 5) return 1;
		if(PlayerInfo[playerid][Faction] >= 3 && PlayerInfo[playerid][Rank] < 3) return 1;
		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /invite [ID/Name]");
			return 1;
		}
        giveplayerid = strval(tmp);
		if(IsPlayerConnected(giveplayerid))
		{
		    if(giveplayerid != INVALID_PLAYER_ID)
		    {
		        if(PlayerInfo[giveplayerid][Faction]!=0) { SendClientMessage(playerid, COLOR_LIGHTRED, "(( The user is already in a faction ))."); return 1; }
		        PlayerInfo[giveplayerid][Faction] = PlayerInfo[playerid][Faction];
		        PlayerInfo[giveplayerid][Rank] = 1;
				format(string, sizeof(string), "* %s accepts you in a faction, congratulations.", NombreEx(playerid));
				SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
				format(string, sizeof(string), "* You have accepted %s in your faction.", NombreEx(giveplayerid));
				SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
			}
		}
		else
		{
			SendClientMessage(playerid, COLOR_LIGHTRED, "(( Player not connected )).");
		}
		return 1;
	}
	if(!strcmp(cmd, "/fire"))
	{
	    if(PlayerInfo[playerid][Faction] == 0) return 1;
		if(PlayerInfo[playerid][Faction] == 1 && PlayerInfo[playerid][Rank] < 5) return 1;
		if(PlayerInfo[playerid][Faction] == 2 && PlayerInfo[playerid][Rank] < 5) return 1;
		if(PlayerInfo[playerid][Faction] >= 3 && PlayerInfo[playerid][Rank] < 3) return 1;
		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /fire [ID/Name]");
			return 1;
		}
        giveplayerid = strval(tmp);
		if(IsPlayerConnected(giveplayerid))
		{
		    if(giveplayerid != INVALID_PLAYER_ID)
		    {
		        if(PlayerInfo[giveplayerid][Faction]!=PlayerInfo[playerid][Faction]) { SendClientMessage(playerid, COLOR_LIGHTRED, "(( You guys are not in the same faction ))."); return 1; }
		        PlayerInfo[giveplayerid][Faction]=0;
		        PlayerInfo[giveplayerid][Rank]=0;
				format(string, sizeof(string), "* %s has sacked you from the faction.", NombreEx(playerid));
				SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
				format(string, sizeof(string), "* You have sacked %s from your faction.", NombreEx(giveplayerid));
				SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
			}
		}
		else
		{
			SendClientMessage(playerid, COLOR_LIGHTRED, "(( Player not connected )).");
		}
		return 1;
	}
	if(!strcmp(cmd, "/rank"))
	{
		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /rank [ID/Name] [number]");
			if(PlayerInfo[playerid][Faction] == 1 && PlayerInfo[playerid][Rank] == 5)
			{
			    SendClientMessage(playerid, COLOR_GREY, "[1] Cadet  [2] Official");
				SendClientMessage(playerid, COLOR_GREY, "[3] Detective  [4] Major");
				SendClientMessage(playerid, COLOR_GREY, "[5] Superintendent");
			}
			else if(PlayerInfo[playerid][Faction] == 2 && PlayerInfo[playerid][Rank] == 5)
			{
			    SendClientMessage(playerid, COLOR_GREY, "[1] Paramedic");
				SendClientMessage(playerid, COLOR_GREY, "[2] Fireman  [3] Firemen coordinator");
				SendClientMessage(playerid, COLOR_GREY, "[4] Doctor");
				SendClientMessage(playerid, COLOR_GREY, "[5] Hospital director");
			}
			else if(PlayerInfo[playerid][Faction] == 3 && PlayerInfo[playerid][Rank] == 3)
			{
			    SendClientMessage(playerid, COLOR_GREY, "[1] Apprentice  [2] Journalist");
				SendClientMessage(playerid, COLOR_GREY, "[3] Director ");
			}
            else if(PlayerInfo[playerid][Faction] > 3 && PlayerInfo[playerid][Rank] == 3)
			{
			    SendClientMessage(playerid, COLOR_GREY, "[1] Rookie  [2] Gangster");
				SendClientMessage(playerid, COLOR_GREY, "[3] Leader");
			}
			return 1;
		}
		new level;
		giveplayerid = strval(tmp);
		tmp = strtok(cmdtext, idx);
		level = strval(tmp);
		if (1 <= PlayerInfo[playerid][Faction] <= 2 && PlayerInfo[playerid][Rank] == 5 || 2<PlayerInfo[playerid][Faction] && PlayerInfo[playerid][Rank] == 3)
		{
		    if(IsPlayerConnected(giveplayerid))
		    {
		        if(giveplayerid != INVALID_PLAYER_ID)
		        {
					if(PlayerInfo[playerid][Faction]!=PlayerInfo[giveplayerid][Faction]) { return 1; }
					PlayerInfo[giveplayerid][Rank] = level;
					format(string, sizeof(string), "* The leader %s has assigned you the rank %d.", NombreEx(playerid),level);
					SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
					format(string, sizeof(string), "* You have assigned to %s the rank %d.", NombreEx(giveplayerid),level);
					SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
				}
			}
		}
		return 1;
	}
	if(!strcmp(cmdtext, "/onduty"))
	{
		if(PlayerInfo[playerid][Faction] == 1)
		{
			if (PlayerToPoint(5, playerid,255.3,77.4,1003.6))
			{
				if(OnDuty[playerid]==0)
		        {
		            new uniforme = (PlayerInfo[playerid][Rank] - 1);
		            if(PlayerInfo[playerid][Sex] == 1) { SetPlayerSkin(playerid, UniformesPoliHombre[uniforme]); }
					else { SetPlayerSkin(playerid, UniformesPoliMujer[uniforme]); }
	                format(string, sizeof(string), "* The agent %s puts on the uniform and takes the badge.", NombreEx(playerid));
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					SetPlayerArmour(playerid, 50);
					PlayerInfo[playerid][One] = 2;
					PlayerInfo[playerid][OneAmount] = 7;
					PlayerInfo[playerid][Two] = 19;
					PlayerInfo[playerid][TwoAmount] = 7;
					PlayerInfo[playerid][Three] = 19;
					PlayerInfo[playerid][ThreeAmount] = 7;
					PlayerInfo[playerid][Four] = 10;
					PlayerInfo[playerid][FourAmount] = 500;
					PlayerInfo[playerid][Five] = 17;
					PlayerInfo[playerid][FiveAmount] = 1;
					OnDuty[playerid] = 1;
					return 1;
				}
				else if(OnDuty[playerid]==1)
				{
				    format(string, sizeof(string), "* The agent %s takes off the uniform and leaves it in the locker.", NombreEx(playerid));
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					SetPlayerArmour(playerid, 0);
					SetPlayerSkin(playerid, PlayerInfo[playerid][Skin]);
                    OnDuty[playerid] = 0;
					return 1;
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_LIGHTRED, "You are not in the locker room.");
				return 1;
			}
		}
		else if(PlayerInfo[playerid][Faction] == 2)
		{
		    if(!PlayerToPoint(6,playerid,1943.52,-1464.51,498.753))
			{
			    SendClientMessage(playerid, COLOR_LIGHTRED, "You are not in the locker room.");
				return 1;
			}
   			if(OnDuty[playerid] == 0)
   			{
       			new uniforme = (PlayerInfo[playerid][Rank]-1);
	            if(PlayerInfo[playerid][Sex]==1) { SetPlayerSkin(playerid, UniformesMediHombre[uniforme]); }
				else { SetPlayerSkin(playerid, UniformesMediMujer[uniforme]); }
	            format(string, sizeof(string), "* %s puts on the official uniform.", sendername);
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				PlayerInfo[playerid][Five] = 35;
				PlayerInfo[playerid][FiveAmount] = 0;
				OnDuty[playerid]=1;
   			}
   			else
   			{
                format(string, sizeof(string), "* %s takes off the uniform and leaves it in the locker.", sendername);
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				SetPlayerArmour(playerid, 0);
				SetPlayerSkin(playerid, PlayerInfo[playerid][Skin]);
                OnDuty[playerid] = 0;
				return 1;
			}
		}
		return 1;
	}
	if(!strcmp(cmdtext, "/equipment"))
    {
        if(PlayerInfo[playerid][Faction]!=1 || OnDuty[playerid]==0 ) { return 1; }
        if(!PlayerToPoint(5, playerid,255.3,77.4,1003.6)) { return 1; }
		ShowPlayerDialog(playerid,27, DIALOG_STYLE_LIST, "Equipments", "Motorbike uniform\nRiot police\nSWAT Assault\nSWAT Sniper", "Put on", "Exit");
   		return 1;
	}
	if(!strcmp(cmdtext, "/tow"))
	{
		if(PlayerInfo[playerid][Faction] != 1) { return 1; }
		if(IsPlayerInAnyVehicle(playerid))
		{
			if(GetVehicleModel(GetPlayerVehicleID(playerid)) != 525) { return SendClientMessage(playerid, COLOR_LIGHTRED, "You need to be in a tow truck."); }
			if(GetPlayerState(playerid) != 2) { return SendClientMessage(playerid, COLOR_LIGHTRED, "You gotta be the driver to be able to tow."); }
			new Float:pX,Float:pY,Float:pZ;
			GetPlayerPos(playerid,pX,pY,pZ);
			new Float:vX,Float:vY,Float:vZ;
			new Found=0;
			new vid=0;
			while((vid<MAX_VEHICLES)&&(!Found))
			{
				vid++;
				GetVehiclePos(vid,vX,vY,vZ);
				if((floatabs(pX-vX)<7.0)&&(floatabs(pY-vY)<7.0)&&(floatabs(pZ-vZ)<7.0)&&(vid!=GetPlayerVehicleID(playerid)))
				{
					Found=1;
					if(IsTrailerAttachedToVehicle(GetPlayerVehicleID(playerid)))
					{
						DetachTrailerFromVehicle(GetPlayerVehicleID(playerid));
					}
					else
					{
						AttachTrailerToVehicle(vid,GetPlayerVehicleID(playerid));
					}
				}
			}
			if(!Found) { SendClientMessage(playerid,COLOR_LIGHTRED,"There is no vehicle nearby to be towed."); }
		}
		else
		{
			SendClientMessage(playerid, COLOR_LIGHTRED, "You cannot tow by foot.");
		}
		return 1;
	}
	if(!strcmp(cmd, "/handcuff"))
	{
		if(PlayerInfo[playerid][Faction] != 1) { return 1; }
	    tmp = strtok(cmdtext, idx);
		if(!strlen(tmp)) {
			SendClientMessage(playerid, COLOR_GREY, "Usage: /handcuff [ID/Name]");
			return 1;
		}
		giveplayerid = strval(tmp);
	    if(IsPlayerConnected(giveplayerid))
		{
		    if(giveplayerid != INVALID_PLAYER_ID)
		    {
				if (ProxDetectorS(8.0, playerid, giveplayerid))
				{
				    format(string, sizeof(string), "* You have been handcuffed by the police officer %s.", NombreEx(playerid));
					SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
					format(string, sizeof(string), "* You have handcuffed %s.", NombreEx(giveplayerid));
                    SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
                    ApplyAnimation(giveplayerid, "SWORD", "sword_block", 4.1, 0, 1, 1, 1, 1, 1);
                    LoopingAnim(giveplayerid, "SWORD", "sword_block", 4.1, 0, 1, 1, 1, 1);
                    LoopingAnim(giveplayerid, "SWORD", "sword_block", 4.1, 0, 1, 1, 1, 1);
					format(string, sizeof(string), "* %s has handcuffed %s.", sendername ,giveplayer);
					ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					GameTextForPlayer(giveplayerid, "~r~Handcuffed", 2500, 3);
					SetPlayerAttachedObject(giveplayerid, 2, 19418, 6, -0.011000, 0.028000, -0.022000, -15.600012, -33.699977, -81.700035, 0.891999, 1.000000, 1.168000);
					SetPlayerSpecialAction(giveplayerid,SPECIAL_ACTION_CUFFED);
	    		}
				else
				{
				    SendClientMessage(playerid, COLOR_LIGHTRED, "That person is too far.");
				    return 1;
				}
			}
		}
		else
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED, "(( That player is not connected )).");
		    return 1;
		}
		return 1;
	}
	if(!strcmp(cmd, "/free"))
	{
		if(PlayerInfo[playerid][Faction] == 1)
		{
		    tmp = strtok(cmdtext, idx);
			if(!strlen(tmp)) {
				SendClientMessage(playerid, COLOR_GREY, "Usage: /free [ID/Name]");
				return 1;
			}
			giveplayerid = strval(tmp);
			if(IsPlayerConnected(giveplayerid))
			{
				if(giveplayerid != INVALID_PLAYER_ID)
				{
				    if (ProxDetectorS(8.0, playerid, giveplayerid))
					{
		    			format(string, sizeof(string), "* The police officer %s has freed you from the handcuffs.", NombreEx(playerid));
						SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
						format(string, sizeof(string), "* You removed the handcuffs from %s.", NombreEx(giveplayerid));
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						GameTextForPlayer(giveplayerid, "~g~Freed", 2500, 3);
						TogglePlayerControllable(giveplayerid, 1);
						RemovePlayerAttachedObject(playerid, 2);
						SetPlayerSpecialAction(giveplayerid,SPECIAL_ACTION_NONE);
						ApplyAnimation(giveplayerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0);
					}
					else
					{
					    SendClientMessage(playerid, COLOR_LIGHTRED, "That person is too far.");
					    return 1;
					}
				}
			}
			else
			{
			    SendClientMessage(playerid, COLOR_LIGHTRED, "(( The player is not connected )).");
			    return 1;
			}
		}
		else
		{
			SendClientMessage(playerid, COLOR_LIGHTRED, "You cannot remove handcuffs.");
		}
		return 1;
	}
	if(!strcmp(cmd, "/frisk"))
	{
		if(PlayerInfo[playerid][Faction] == 1)
		{
		    tmp = strtok(cmdtext, idx);
			if(!strlen(tmp)) {
				SendClientMessage(playerid, COLOR_GREY, "Usage: /frisk [ID/Name]");
				return 1;
			}
			giveplayerid = strval(tmp);
			if(IsPlayerConnected(giveplayerid))
			{
				if(giveplayerid != INVALID_PLAYER_ID)
				{
				    if (ProxDetectorS(8.0, playerid, giveplayerid))
					{
		    			format(string, sizeof(string), "* Police officer %s is frisking you, checking your pockets and your wallet.", NombreEx(playerid));
						SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
						format(string, sizeof(string), "* You are frisking %s.", NombreEx(giveplayerid));
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						format(string, sizeof(string), "Slot 1: %s (%d)", Obje[PlayerInfo[giveplayerid][One]],PlayerInfo[giveplayerid][OneAmount]);
						SendClientMessage(playerid, COLOR_WHITE, string);
						format(string, sizeof(string), "Slot 2: %s (%d)", Obje[PlayerInfo[giveplayerid][Two]],PlayerInfo[giveplayerid][TwoAmount]);
						SendClientMessage(playerid, COLOR_WHITE, string);
						format(string, sizeof(string), "Slot 3: %s (%d)", Obje[PlayerInfo[giveplayerid][Three]],PlayerInfo[giveplayerid][ThreeAmount]);
						SendClientMessage(playerid, COLOR_WHITE, string);
						format(string, sizeof(string), "Slot 4: %s (%d)", Obje[PlayerInfo[giveplayerid][Four]],PlayerInfo[giveplayerid][FourAmount]);
						SendClientMessage(playerid, COLOR_WHITE, string);
						format(string, sizeof(string), "Slot 5: %s (%d)", Obje[PlayerInfo[giveplayerid][Five]],PlayerInfo[giveplayerid][FiveAmount]);
						SendClientMessage(playerid, COLOR_WHITE, string);
						format(string, sizeof(string), "Hand: %s (%d)", Obje[PlayerInfo[giveplayerid][Hand]],PlayerInfo[giveplayerid][HandAmount]);
						SendClientMessage(playerid, COLOR_WHITE, string);
						format(string, sizeof(string), "Money: $ %d", GetPlayerMoney(giveplayerid));
						SendClientMessage(playerid, COLOR_WHITE, string);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, "-----");
					}
					else
					{
					    SendClientMessage(playerid, COLOR_LIGHTRED, "The person is not next to you.");
					    return 1;
					}
				}
			}
			else
			{
			    SendClientMessage(playerid, COLOR_LIGHTRED, "(( The player is not connected )).");
			    return 1;
			}
		}
		return 1;
	}
	if(!strcmp(cmd, "/ticket"))
	{
		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /ticket [ID/Name] [Economic sanction]");
			return 1;
		}
		new level;
		giveplayerid = strval(tmp);
		tmp = strtok(cmdtext, idx);
		level = strval(tmp);
		if (PlayerInfo[playerid][Faction] == 1)
		{
		    if(IsPlayerConnected(giveplayerid))
		    {
		        if(giveplayerid != INVALID_PLAYER_ID)
		        {
					GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
					GetPlayerName(playerid, sendername, sizeof(sendername));
					PlayerInfo[giveplayerid][Bank] -= level;
					format(string, sizeof(string), "* The police officer %s has ticked you with %d dollars, taken from your bank account.", sendername,level);
					SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
					format(string, sizeof(string), "* You have ticketed %s with %d dollars.", giveplayer,level);
					SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
				}
			}
		}
    	return 1;
	}
	if(!strcmp(cmd, "/arrest"))
	{
		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /arrest [ID/Name] [Time in paydays]");
			return 1;
		}
		new level;
		giveplayerid = strval(tmp);
		tmp = strtok(cmdtext, idx);
		level = strval(tmp);
		if (PlayerInfo[playerid][Faction] == 1)
		{
		    if(IsPlayerConnected(giveplayerid))
		    {
		        if(giveplayerid != INVALID_PLAYER_ID)
		        {
					PlayerInfo[giveplayerid][Prison] = level;
					format(string, sizeof(string), "* The police officer %s has arrested you for %d paydays.", NombreEx(playerid),level);
					SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
					format(string, sizeof(string), "* You have jailed %s for %d paydays.", NombreEx(giveplayerid),level);
					SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
				}
			}
		}
    	return 1;
	}
	if(!strcmp(cmdtext, "/forcehousedoor"))
    {
        if(PlayerInfo[playerid][Faction] != 1) { return 1; }
        for(new i = 0; i < sizeof(House); i++)
		{
			if (PlayerToPoint(1, playerid,House[i][Entrancex], House[i][Entrancey], House[i][Entrancez]))
			{
				SetPlayerPos(playerid,House[i][Exitx],House[i][Exity],House[i][Exitz]);
				SetPlayerInterior(playerid, House[i][Interior]);
				SetPlayerVirtualWorld(playerid,i);
				CasaVw[playerid]=i;
				TogglePlayerControllable(playerid,0);
				SetTimerEx("Descongelacion",250,0,"i",playerid);
				House[i][Locked] = 0;
				ProxDetector(50.0, playerid, "* You hear a noise from the entrance!", COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN);
	  		}
		}
   		return 1;
	}
	if(!strcmp(cmdtext, "/registerhouse"))
	{
	    if(PlayerInfo[playerid][Faction]!=1) { return 1; }
	    if(CasaVw[playerid] == 0) { SendClientMessage(playerid, COLOR_LIGHTRED, "You are not at a house."); return 1; }
	    key = CasaVw[playerid];
	    if(PlayerToPoint(30.0, playerid, House[key][Exitx], House[key][Exity], House[key][Exitz]))
	    {
	        if(PlayerInfo[playerid][Hand]!=0) { SendClientMessage(playerid, COLOR_LIGHTRED, "Your hands are busy."); return 1; }
	        new cantidad1 = House[key][Amount1];
	        new cantidad2 = House[key][Amount2];
	        new cantidad3 = House[key][Amount3];
	        format(string,sizeof(string),"%s (%d)\n%s (%d)\n%s (%d)",Obje[House[key][Closet1]],cantidad1,Obje[House[key][Closet2]],cantidad2,Obje[House[key][Closet3]],cantidad3);
        	ShowPlayerDialog(playerid,14,DIALOG_STYLE_LIST,"Closet",string,"Take","No");
	    }
	    else
	    {
     		SendClientMessage(playerid, COLOR_LIGHTRED, "Seemingly you are not at a house.");
	    }
		return 1;
	}
	if(!strcmp(cmd, "/registerboot"))
	{
		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /registerboot [number plate]");
			SendClientMessage(playerid, COLOR_GREY, "Example: /registerboot 51");
			return 1;
		}
		new plate;
		plate = strval(tmp);
		if(plate < 51 || plate > 70)
		{
		    SendClientMessage(playerid, COLOR_GREY, "Error: the minimum is 51, the maximum is 70.");
		    return 1;
		}
		if(PlayerInfo[playerid][Faction] == 1)
		{
		    new idgm;
		    idgm = 0;
  			for(new i; i < 20; i++)
			{
			    if(Carros[i] == plate)
			    {
					idgm = 51+i;
			    }
			}
			if(idgm == 0)
			{
			    SendClientMessage(playerid, COLOR_GREY, "(( Vehicle not spawned )).");
			    return 1;
			}
			new Float:X, Float:Y, Float:Z;
			GetVehiclePos(idgm, X, Y, Z);
			if(IsPlayerInRangeOfPoint(playerid, 6.5, X, Y, Z))
	        {
	            format(string, sizeof(string), "* %s registers the boot of a vehicle.", NombreEx(playerid));
      			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	            format(string, sizeof(string), "Inside the boot: %s (%d)", Obje[Vehicle[plate-51][Maletero]],Vehicle[plate-51][MaleteroCantidad]);
				SendClientMessage(playerid, COLOR_GREEN, string);
	        }
	        else
	        {
	            SendClientMessage(playerid, COLOR_GREY, "Get closer to the vehicle.");
	        }
		}
		else
		{
			SendClientMessage(playerid, COLOR_GREY, "You cannot use this command.");
		}
		return 1;
	}
	if(!strcmp(cmd, "/deductlicencepoint"))
	{
		if(PlayerInfo[playerid][Faction] == 1)
		{
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GREY, "Usage: /deductlicencepoint [ID/Name]");
				return 1;
			}
            giveplayerid = strval(tmp);
			if(IsPlayerConnected(giveplayerid))
			{
			    if(giveplayerid != INVALID_PLAYER_ID)
			    {
			        PlayerInfo[giveplayerid][Licence]-=1;

					format(string, sizeof(string), "* Police has substracted a driving licence point from you, now you have: %d.", PlayerInfo[giveplayerid][Licence]);
					SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
					format(string, sizeof(string), "* You have substracted %s a driving licence point, now has %d remaining.", NombreEx(giveplayerid),PlayerInfo[giveplayerid][Licence]);
					SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_LIGHTRED, "(( Player not connected )).");
			}
		}
		return 1;
	}
	if(!strcmp(cmdtext, "/attend"))
	{
		if(PlayerInfo[playerid][Faction] != 2)	{ return 1; }
  		paramedics = 1;
	   	return 1;
	}
	if(!strcmp(cmd, "/rescue"))
    {
		if(PlayerInfo[playerid][Faction]==2)
		{
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GREY, "Usage: /rescue [ID/Name]");
				return 1;
			}
			giveplayerid = strval(tmp);
			if(IsPlayerConnected(giveplayerid))
			{
				if(giveplayerid != INVALID_PLAYER_ID)
				{
			    	if(ProxDetectorS(2.0, playerid, giveplayerid))
					{
				    	if(giveplayerid == playerid) { SendClientMessage(playerid, COLOR_LIGHTRED, "You cannot rescue yourself."); return 1; }
						if(PlayerInfo[giveplayerid][Dead] == 1)
						{
							format(string, sizeof(string), "* %s has rescued %s successfully.", NombreEx(playerid),NombreEx(giveplayerid));
                            ProxDetector(30.0, playerid, string, COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN);
							format(string, sizeof(string), "* The paramedic %s has rescued you.", NombreEx(playerid));
							SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
							format(string, sizeof(string), "* You have rescued %s.", NombreEx(giveplayerid));
							SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
							SetPlayerHealth(giveplayerid, 50.0);
							TogglePlayerControllable(giveplayerid, 1);
							ApplyAnimation(giveplayerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0);
							PlayerInfo[giveplayerid][Dead] = 0;
						}
						else
						{
						format(string, sizeof(string), "%s is not wounded.", giveplayer);
						SendClientMessage(playerid, COLOR_RED, string);
						}
					}
					else
					{
				    	SendClientMessage(playerid, COLOR_LIGHTRED, "The person is too far to be revived from here.");
				    	return 1;
					}
				}
			}
        }
	    return 1;
 	}
 	if(!strcmp(cmdtext, "/extinguisher"))
	{
		if(PlayerInfo[playerid][Faction] != 2)	{ return 1; }
  		if(GetPlayerVehicleID(playerid)!=24 && GetPlayerVehicleID(playerid)!=25){ return 1; }
  		ResetPlayerWeapons(playerid);
        PlayerInfo[playerid][Hand]=11;
		PlayerInfo[playerid][HandAmount]=500;
		ResetObject(playerid);
	   	return 1;
	}
	if(!strcmp(cmdtext, "/extinguishfire"))
	{
		if(PlayerInfo[playerid][Faction] != 2)	{ return 1; }
		if(!PlayerToPoint(15.5,playerid,1833.4407,-1842.6156,12.5781)) { return 1; }
		DestroyObject(fuegoUno);
		DestroyObject(fuegoDos);
		DestroyObject(humoUno);
		DestroyObject(humoDos);
		format(string, sizeof(string), "* %s extinguishes the fire.", NombreEx(playerid));
 		ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	   	return 1;
	}
 	if(!strcmp(cmd, "/news"))
	{
		if(PlayerInfo[playerid][Faction]!=3)
		{
			SendClientMessage(playerid, COLOR_GREY, "You don't work for San Andreas News.");
			return 1;
		}
		new length = strlen(cmdtext);
		while ((idx < length) && (cmdtext[idx] <= ' '))
		{
			idx++;
		}
		new offset = idx;
		new result[128];
		while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
		{
			result[idx - offset] = cmdtext[idx];
			idx++;
		}
		result[idx - offset] = EOS;
		if(!strlen(result))
		{
			SendClientMessage(playerid, COLOR_GREY, "Usage: /news [Public message]");
			return 1;
		}
		format(string, sizeof(string), "[NEWS]: %s" ,result);
		SendClientMessageToAll(COLOR_GREEN, string);
		printf("%s", string);
		return 1;
	}
	if(!strcmp(cmdtext, "/harvest"))
	{
 		if(PlayerInfo[playerid][Job] == 1)
     	{
     	    if(GetPlayerVehicleID(playerid)!=30)
     	    {
     	        return 1;
     	    }
	       	new randomss;
	        randomss = random(sizeof(PuntosGranja));
	        SetPlayerCheckpoint(playerid, PuntosGranja[randomss][0], PuntosGranja[randomss][1], PuntosGranja[randomss][2], 5.0);
     	}
   		return 1;
	}
	if(!strcmp(cmdtext, "/sweep"))
	{
 		if(PlayerInfo[playerid][Job] == 2 && PlayerToPoint(30,playerid,2191.0098,-1971.7839,13.2836))
     	{
     	    if(GetPlayerVehicleID(playerid)!=31)
     	    {
     	        return 1;
     	    }
	        SetPlayerCheckpoint(playerid, 1418.2, -1646.4, 12.7, 1.0);
     	}
	   	return 1;
	}
	if(!strcmp(cmdtext, "/rubbishroute"))
	{
 		if(PlayerInfo[playerid][Job] == 2 && PlayerToPoint(30,playerid,2191.0098,-1971.7839,13.2836))
     	{
     	    if(GetPlayerVehicleID(playerid)!=32)
     	    {
     	        return 1;
     	    }
     	    Contenedor[playerid]=1;
	        SetPlayerCheckpoint(playerid, 2086.3066,-1833.0544,14.0069, 3.0);
     	}
	   	return 1;
	}
	if(!strcmp(cmdtext, "/deliver"))
    {
        if(PlayerInfo[playerid][Job] != 3) { return 1; }
        if(33 > GetPlayerVehicleID(playerid) || 35 < GetPlayerVehicleID(playerid))
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED, "Get in a Mule to check the deliveries available.");
			return 1;
		}
		new deliveryPda[5][50];
		for(new i = 0; i < 5; i++)
		{
		    if(Repartos[i] == 0) { deliveryPda[i] = "-"; }
		    else { deliveryPda[i] = "Available order"; }
		}
        format(string,sizeof(string),"%s\n%s\n%s\n%s\n%s",deliveryPda[0],deliveryPda[1],deliveryPda[2],deliveryPda[3],deliveryPda[4]);
        ShowPlayerDialog(playerid,25,DIALOG_STYLE_LIST,"Pending orders",string,"Carry out","Cancel");
   		return 1;
	}
	if(!strcmp(cmdtext, "/take"))
    {
        if(PlayerInfo[playerid][Job]!=3) { return 1; }
        if(Repartiendo[playerid] < 1) { return 1; }
        if(PlayerInfo[playerid][Hand] != 0)
        {
            SendClientMessage(playerid, COLOR_LIGHTRED, "Your hands are busy.");
            return 1;
        }
        new Float:X, Float:Y, Float:Z;
		GetVehiclePos(Camion[playerid], X, Y, Z);
		if(IsPlayerInRangeOfPoint(playerid, 6.5, X, Y, Z))
        {
            LoopingAnim(playerid, "CARRY", "crry_prtial",4.1,0,1,1,1,1);
            SetPlayerAttachedObject( playerid, 0, 2969, 1, 0.150000, 0.400000, 0.000000, 0.000000, 100.000000, 0.000000, 1.000000, 1.000000, 1.000000 );
            CarryingBox[playerid] = 1;
        }
   		return 1;
	}
	if(!strcmp(cmdtext, "/gasolineroute"))
    {
        if(PlayerInfo[playerid][Job] != 3) { return 1; }
        if(GetPlayerVehicleID(playerid) != 36)
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED, "Get in the big truck.");
			return 1;
		}
        if(Repartiendo[playerid]!=0) { return 1; }
        SetPlayerCheckpoint(playerid, 2788.7153,-2474.6316,14.6600, 8.0);
        SendClientMessage(playerid, COLOR_WHITE, "[Boss] Tow the gasoline tanker, take extreme precaution.");
        Repartiendo[playerid] = -1;
   		return 1;
	}
	if(!strcmp(cmdtext, "/deliverpizza"))
	{
 		if(PlayerInfo[playerid][Job] == 4 && PlayerToPoint(6,playerid,378.4542,-114.2976,1001.4922))
     	{
     	    if(PlayerInfo[playerid][Hand] != 29)
     	    {
     	        SendClientMessage(playerid, COLOR_LIGHTRED, "You need to have a pizza in your hand, buy one.");
     	        return 1;
     	    }
     	    new rand = random(20);
          	rand += 1;
          	SetPlayerCheckpoint(playerid,House[rand][Entrancex],House[rand][Entrancey],House[rand][Entrancez],2);
          	SendClientMessage(playerid, COLOR_YELLOW, "[Boss] Go outside, get on the motorbike and deliver the pizza.");
        }
        else
        {
            SendClientMessage(playerid, COLOR_LIGHTRED, "Go to the pizzeria kitchen.");
        }
   		return 1;
	}
	if(!strcmp(cmdtext, "/busroute"))
	{
 		if(PlayerInfo[playerid][Job] == 5 && PlayerToPoint(30,playerid,1182.1,-1795.9,13.1))
     	{
     	    if(GetPlayerVehicleID(playerid)!=40)
     	    {
     	        return 1;
     	    }
     	    Autobus[playerid]=1;
	        SetPlayerCheckpoint(playerid, 1613.2216,-2321.5896,-2.7568, 4.0);
	        SendClientMessageToAll(COLOR_GREEN, "[NOTICE] The bus is about to start its route. List of stops:");
	        SendClientMessageToAll(COLOR_BLUE, "Airport -> El Corona -> Idlewood -> Glen Park -> Mulholland -> Cemetery ->");
     	   	SendClientMessageToAll(COLOR_BLUE, "Grotti Dealership -> Rodeo -> Marina -> Bus Station");
     		SendClientMessageToAll(COLOR_GREEN,"___________________________________________________");
        }
   		return 1;
	}
	if(!strcmp(cmdtext, "/mission"))
    {
        if(PlayerInfo[playerid][Job]!=8) { return 1; }
        if(Mision[playerid]!=0) { return 1; }
		if(PlayerInfo[playerid][CriminalSkill] == 0)
		{
        	SendClientMessage(playerid, COLOR_LIGHTYELLOW, "[Mobster SMS] Prepare a /molotov cocktail with a beer and a gasoline can.");
        	SendClientMessage(playerid, COLOR_LIGHTYELLOW, "[Mobster SMS] Do it nearby Unity Station, I want you to set afire a store of snitches.");
        }
        else if(PlayerInfo[playerid][CriminalSkill] == 1)
		{
        	SendClientMessage(playerid, COLOR_LIGHTYELLOW, "[Mobster SMS] Get a picklock and rob an ATM. (/robatm)");
        	SendClientMessage(playerid, COLOR_LIGHTYELLOW, "[Mobster SMS] Once you get the money bag full of money, run away to where we first met.");
        }
        else if(PlayerInfo[playerid][CriminalSkill] == 2)
        {
            SetPlayerCheckpoint(playerid, 1807.1915,-1808.9478,3.9844, 1.0);
            Mision[playerid]=2;
            SendClientMessage(playerid, COLOR_LIGHTYELLOW, "[Mobster SMS] I have a problem... I forgot something in the aqueduct, go find it, you can keep it.");
        }
        else
        {
            if(delito == 1) { SendClientMessage(playerid, COLOR_LIGHTRED, "[Mobster SMS] Not safe to steal a vehicle for now, wait to next payday."); return 1; }
            if(Mision[playerid]!=0) { return 1; }
            new encontrado = 0;
            for (new i = 0; i < 20; i++)
			{
			    if(Carros[i]!=0 && Carros[i]!=PlayerInfo[playerid][VehicleKey] && encontrado==0)
			    {
			        encontrado=Carros[i];
			        Mision[playerid]=i+51;
			        Vehicle[Carros[i]-51][Tiempo]=0;
			    }
			}
			if(encontrado!=0)
			{
			    delito=1;
				format(string, sizeof(string),"[Mobster SMS] I want you to bring me a vehicle with this number plate: LS %d.",encontrado);
				SendClientMessage(playerid, COLOR_LIGHTYELLOW, string);
				SendClientMessage(playerid, COLOR_YELLOW, "To /force the door and do the /bridgecircuit you need a picklock.");
			}
			else
			{
			    SendClientMessage(playerid, COLOR_LIGHTRED, "[Mobster SMS] Right now I can't find anything, talk to me later on.");
			}
        }
   		return 1;
	}
	if(!strcmp(cmdtext, "/skill"))
    {
        format(string, sizeof(string),"Your criminal skill is: %d.",PlayerInfo[playerid][CriminalSkill]);
		SendClientMessage(playerid, COLOR_GREEN, string);
   		return 1;
	}
	if(!strcmp(cmdtext, "/molotov"))
    {
        if(PlayerInfo[playerid][Job]!=8) { return 1; }
		if(PlayerInfo[playerid][Hand]!=36) { return 1; }
		new cervecita = 0;
		if(PlayerInfo[playerid][One]==33) { cervecita=1; PlayerInfo[playerid][One]=0; PlayerInfo[playerid][OneAmount]=0; }
		else if(PlayerInfo[playerid][Two]==33) { cervecita=2; PlayerInfo[playerid][Two]=0; PlayerInfo[playerid][TwoAmount]=0; }
		else if(PlayerInfo[playerid][Three]==33) { cervecita=3; PlayerInfo[playerid][Three]=0; PlayerInfo[playerid][ThreeAmount]=0; }
		else if(PlayerInfo[playerid][Four]==33) { cervecita=4; PlayerInfo[playerid][Four]=0; PlayerInfo[playerid][FourAmount]=0; }
		else if(PlayerInfo[playerid][Five]==33) { cervecita=5; PlayerInfo[playerid][Five]=0; PlayerInfo[playerid][FiveAmount]=0; }
		if(cervecita>0)
		{
   			RemovePlayerAttachedObject(playerid, 0);
   			if(PlayerInfo[playerid][CriminalSkill]==0)
   			{
   				SetPlayerCheckpoint(playerid,1833.4407,-1842.6156,13.5781,8.0);
   				SendClientMessage(playerid, COLOR_LIGHTYELLOW, "[Mobster] Head to the Unity Station grocery and throw the Molotov cocktail.");
   			}
   			GivePlayerWeapon(playerid, 18, 1);
   			PlayerInfo[playerid][Hand]=13;
   			PlayerInfo[playerid][HandAmount]=1;
   			SendClientMessage(playerid, COLOR_LIGHTRED, "* You have prepared a Molotov cocktail, be careful with burning yourself.");
		}
   		return 1;
	}
	if(!strcmp(cmdtext, "/robatm"))
    {
        if(Mision[playerid]!=0) { SendClientMessage(playerid, COLOR_LIGHTRED, "You're busy with a mission."); return 1; }
        if(delito == 1)
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED, "[Mobster] It is not safe to commit a crime now, try later on.");
		    return 1;
		}
		if(PlayerInfo[playerid][Job] != 8)
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED, "(( You need the job of criminal to rob ATMs )).");
		    return 1;
		}
		if(PlayerInfo[playerid][Hand] != 37)
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED, "You need a picklock to rob the ATM.");
		    return 1;
		}
		if(PlayerInfo[playerid][CriminalSkill] < 1)
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED, "You don't have skills to do this yet.");
		    return 1;
		}
		PlayerInfo[playerid][HandAmount]-=1;
		if(PlayerInfo[playerid][HandAmount]<1)
		{
		    PlayerInfo[playerid][Hand] = 0;
   			PlayerInfo[playerid][HandAmount] = 0;
   			RemovePlayerAttachedObject(playerid, 0);
   			SendClientMessage(playerid, COLOR_LIGHTRED, "* Your picklock got overused and broke.");
		}
		if(PlayerToPoint(3.1,playerid,1336.95, -1745, 13.2))
		{
		    delito=1;
		    SetPlayerAttachedObject(playerid, 3, 1550, 1, 0.1, -0.3, 0, 0, 70, 0, 1, 1, 1);
		    SetPlayerCheckpoint(playerid, 1295.3774,-985.6821,32.6953, 1.0);
		    LoopingAnim(playerid,"BOMBER","BOM_Plant",4.1,0,0,0,0,0);
		    GameTextForPlayer(playerid, "~w~Forcing the ATM",3500,3);
		    Mision[playerid]=1;
		    SendAlertMessage(1,COLOR_BLUE,"[Police Station] An ATM is being robbed at the marked area on the radar.",1336.95, -1745, 13.2);
		    ProxDetector(50.0, playerid, "* Some neighbours draw their phones and call police.", COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN);
		}
		else if(PlayerToPoint(3.1,playerid,1834.2, -1851, 13))
		{
		    delito=1;
		    SetPlayerAttachedObject(playerid, 3, 1550, 1, 0.1, -0.3, 0, 0, 70, 0, 1, 1, 1);
		    SetPlayerCheckpoint(playerid, 1295.3774,-985.6821,32.6953, 1.0);
		    LoopingAnim(playerid,"BOMBER","BOM_Plant",4.1,0,0,0,0,0);
		    GameTextForPlayer(playerid, "~w~Forcing the ATM",3500,3);
		    Mision[playerid]=1;
		    SendAlertMessage(1,COLOR_BLUE,"[Police Station] An ATM is being robbed at the marked area on the radar.",1834.2, -1851, 13);
		    ProxDetector(50.0, playerid, "* Some neighbours draw their phones and call police.", COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN);
		}
        else if(PlayerToPoint(3.1,playerid,1151.6, -1385.5, 13.4))
        {
            delito=1;
            SetPlayerAttachedObject(playerid, 3, 1550, 1, 0.1, -0.3, 0, 0, 70, 0, 1, 1, 1);
            SetPlayerCheckpoint(playerid, 1295.3774,-985.6821,32.6953, 1.0);
		    LoopingAnim(playerid,"BOMBER","BOM_Plant",4.1,0,0,0,0,0);
		    GameTextForPlayer(playerid, "~w~Forcing the ATM",3500,3);
		    Mision[playerid]=1;
		    SendAlertMessage(1,COLOR_BLUE,"[Police Station] An ATM is being robbed at the marked area on the radar.",1151.6, -1385.5, 13.4);
		    ProxDetector(50.0, playerid, "* Some neighbours draw their phones and call police.", COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN);
        }
        else if(PlayerToPoint(3.1,playerid,560.90002, -1293.999, 16.89))
        {
            delito=1;
            SetPlayerAttachedObject(playerid, 3, 1550, 1, 0.1, -0.3, 0, 0, 70, 0, 1, 1, 1);
            SetPlayerCheckpoint(playerid, 1295.3774,-985.6821,32.6953, 1.0);
		    LoopingAnim(playerid,"BOMBER","BOM_Plant",4.1,0,0,0,0,0);
		    GameTextForPlayer(playerid, "~w~Forcing the ATM",3500,3);
		    Mision[playerid]=1;
		    SendAlertMessage(1,COLOR_BLUE,"[Police Station] An ATM is being robbed at the marked area on the radar.",560.90002, -1293.999, 16.89);
            ProxDetector(50.0, playerid, "* Some neighbours draw their phones and call police.", COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN);
		}
        else {  }
   		return 1;
	}
	if(!strcmp(cmdtext, "/force"))
    {
        if(Mision[playerid]<51) { SendClientMessage(playerid, COLOR_LIGHTRED, "[Mobster] I haven't asked you to force a vehicle."); return 1; }
        if(PlayerInfo[playerid][Hand]!=37) { SendClientMessage(playerid, COLOR_LIGHTRED, "You need a picklock."); return 1; }
        if(PlayerInfo[playerid][HandAmount]<1)
        {
            PlayerInfo[playerid][Hand] = 0;
	   		PlayerInfo[playerid][HandAmount] = 0;
	   		RemovePlayerAttachedObject(playerid, 0);
	   		SendClientMessage(playerid, COLOR_LIGHTRED, "* The picklock got overused and broke.");
            return 1;
        }
        new Float:X, Float:Y, Float:Z;
		GetVehiclePos(Mision[playerid], X, Y, Z);
		if(IsPlayerInRangeOfPoint(playerid, 6.5, X, Y, Z))
        {
            new Logra;
            Logra = random(5);
		    switch(Logra)
		   	{
		    	case 0:
				{
				    SendClientMessage(playerid, COLOR_LIGHTRED, "* You failed and the alarm has raised!");
					new engine,lights,alarm,doors,bonnet,boot,objective;
            		GetVehicleParamsEx(Mision[playerid],engine,lights,alarm,doors,bonnet,boot,objective);
             		SetVehicleParamsEx(Mision[playerid],engine,lights,1,doors,bonnet,boot,objective);
             		GameTextForPlayer(giveplayerid, "~r~The alarm has raised!", 2500, 3);
             		LoopingAnim(playerid,"BOMBER","BOM_Plant",4.1,0,0,0,0,0);
             		PlayerInfo[playerid][HandAmount]-=1;
             		SendAlertMessage(1,COLOR_BLUE,"[Police Station] A vehicle is being forced at the marked area on the radar, the alarm just raised.",X,Y,Z);
				}
		     	case 1:
			 	{
			 	    SendClientMessage(playerid, COLOR_LIGHTGREEN, "Vehicle door forced successfully!");
			 	    new engine,lights,alarm,doors,bonnet,boot,objective;
            		GetVehicleParamsEx(Mision[playerid],engine,lights,alarm,doors,bonnet,boot,objective);
             		SetVehicleParamsEx(Mision[playerid],engine,lights,alarm,0,bonnet,boot,objective);
             		GameTextForPlayer(giveplayerid, "~g~Door forced", 2500, 3);
             		LoopingAnim(playerid,"BOMBER","BOM_Plant",4.1,0,0,0,0,0);
             		PlayerInfo[playerid][HandAmount]-=1;
			 	}
			 	case 2,3,4:
			 	{
			 	    SendClientMessage(playerid, COLOR_LIGHTRED, "* You failed.");
			 	    LoopingAnim(playerid,"BOMBER","BOM_Plant",4.1,0,0,0,0,0);
			 	    PlayerInfo[playerid][HandAmount]-=1;
			 	}
		    }
        }
        else
        {
            SendClientMessage(playerid, COLOR_LIGHTRED, "[Mobster] You aren't close to the vehicle I asked you for.");
        }
   		return 1;
	}
	if(!strcmp(cmdtext, "/bridgecircuit"))
    {
        if(Mision[playerid]==GetPlayerVehicleID(playerid) && PlayerInfo[playerid][Hand]==37 && PlayerInfo[playerid][HandAmount]>0)
        {
            PlayerInfo[playerid][HandAmount]-=1;
            if(PlayerInfo[playerid][HandAmount]<1)
	        {
	            PlayerInfo[playerid][Hand] = 0;
		   		PlayerInfo[playerid][HandAmount] = 0;
		   		RemovePlayerAttachedObject(playerid, 0);
		   		SendClientMessage(playerid, COLOR_LIGHTRED, "* The picklock got overused and broke!");
	        }
            new Logra;
            Logra = random(5);
		    switch(Logra)
		   	{
		    	case 0,1,2,3:
				{
				    SendClientMessage(playerid, COLOR_LIGHTRED, "* You failed.");
				}
				case 4:
				{
				    new engine,lights,alarm,doors,bonnet,boot,objective;
		      		GetVehicleParamsEx(Mision[playerid],engine,lights,alarm,doors,bonnet,boot,objective);
		      		SetVehicleParamsEx(Mision[playerid],1,lights,alarm,doors,bonnet,boot,objective);
		      		SetPlayerCheckpoint(playerid, 2650.3730,-2117.0586,13.64, 5.0);
		   			GameTextForPlayer(giveplayerid, "~g~Engine on", 2500, 3);
		   			SendClientMessage(playerid, COLOR_YELLOW, "* You managed to do the bridge circuit, give the car to the mobster.");
		   			Motor[GetPlayerVehicleID(playerid)] = 1;
				}
			}
        }
   		return 1;
	}
	if(!strcmp(cmd, "/pickpocket"))
	{
 		if(PlayerInfo[playerid][Job] != 8) { return 1; }
 		if(PlayerInfo[playerid][CriminalSkill] < 4)
 		{
 		    SendClientMessage(playerid, COLOR_LIGHTRED, "(( You need to reach the skill 4 of criminal )).");
 		    return 1;
 		}
 		if(PlayerInfo[playerid][Five] != 0)
 		{
 		    SendClientMessage(playerid, COLOR_LIGHTRED, "(( You need to have the fifth slot of your pocket empty )).");
 		    return 1;
 		}
		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp)) {
			SendClientMessage(playerid, COLOR_GREY, "Usage: /pickpocket [ID/Name]");
			return 1;
		}
		giveplayerid = strval(tmp);
		if(IsPlayerConnected(giveplayerid))
		{
			if(giveplayerid != INVALID_PLAYER_ID)
			{
   				if(ProxDetectorS(0.65, playerid, giveplayerid))
				{
				    if(giveplayerid == playerid)
				    {
				        return 1;
				    }
    				new bolsillo;
		            bolsillo = random(6);
				    switch(bolsillo)
				   	{
				    	case 0: SendClientMessage(playerid, COLOR_LIGHTYELLOW, "* That pocket is carefully protected by the victim, try again.");
	  					case 1:
						{
						    if(PlayerInfo[giveplayerid][Two] == 0)
						    {
						        SendClientMessage(playerid, COLOR_LIGHTYELLOW, "* This pocket is empty, you can try again.");
						    }
						    else
						    {
						        PlayerInfo[playerid][Five] = PlayerInfo[giveplayerid][Two];
						        PlayerInfo[playerid][FiveAmount] = PlayerInfo[giveplayerid][TwoAmount];
						        PlayerInfo[giveplayerid][Two] = 0;
						        PlayerInfo[giveplayerid][TwoAmount] = 0;
						        format(string, sizeof(string), "* You have stolen %s and keep it hidden in your pocket.", Obje[PlayerInfo[playerid][Five]]);
								SendClientMessage(playerid, COLOR_YELLOW, string);
						    }
	  					}
	  					case 2:
						{
						    if(PlayerInfo[giveplayerid][Three] == 0)
						    {
						        SendClientMessage(playerid, COLOR_LIGHTYELLOW, "* This pocket is empty, you can try again.");
						    }
						    else
						    {
						        PlayerInfo[playerid][Five] = PlayerInfo[giveplayerid][Three];
						        PlayerInfo[playerid][FiveAmount] = PlayerInfo[giveplayerid][ThreeAmount];
						        PlayerInfo[giveplayerid][Three] = 0;
						        PlayerInfo[giveplayerid][ThreeAmount] = 0;
						        format(string, sizeof(string), "* You have stolen %s and keep it hidden in your pocket.", Obje[PlayerInfo[playerid][Five]]);
								SendClientMessage(playerid, COLOR_YELLOW, string);
								if(PlayerInfo[playerid][CriminalSkill] == 4)
								{
								    SendClientMessage(playerid, COLOR_GREEN, "Your criminal skill has reached the maximum, level 5.");
								    PlayerInfo[playerid][CriminalSkill] = 5;
								}
						    }
	  					}
	  					case 3:
						{
						    if(PlayerInfo[giveplayerid][Four] == 0)
						    {
						        SendClientMessage(playerid, COLOR_LIGHTYELLOW, "* This pocket is empty, you can try again.");
						    }
						    else
						    {
						        PlayerInfo[playerid][Five] = PlayerInfo[giveplayerid][Four];
						        PlayerInfo[playerid][FiveAmount] = PlayerInfo[giveplayerid][FourAmount];
						        PlayerInfo[giveplayerid][Four] = 0;
						        PlayerInfo[giveplayerid][FourAmount] = 0;
						        format(string, sizeof(string), "* You have stolen %s and keep it hidden in your pocket.", Obje[PlayerInfo[playerid][Five]]);
								SendClientMessage(playerid, COLOR_YELLOW, string);
						    }
	  					}
	  					case 4:
						{
						    if(PlayerInfo[giveplayerid][Five] == 0)
						    {
						        SendClientMessage(playerid, COLOR_LIGHTYELLOW, "* This pocket is empty, you can try again.");
						    }
						    else
						    {
						        PlayerInfo[playerid][Five] = PlayerInfo[giveplayerid][Five];
						        PlayerInfo[playerid][FiveAmount] = PlayerInfo[giveplayerid][FiveAmount];
						        PlayerInfo[giveplayerid][Five] = 0;
						        PlayerInfo[giveplayerid][FiveAmount] = 0;
						        format(string, sizeof(string), "* You have stolen %s and keep it hidden in your pocket.", Obje[PlayerInfo[playerid][Five]]);
								SendClientMessage(playerid, COLOR_YELLOW, string);
						    }
	  					}
	  					case 5:
						{
						    SendClientMessage(playerid, COLOR_RED, "* You failed and the victim noticed !");
						    SendClientMessage(giveplayerid, COLOR_LIGHTRED, "* Somebody touched your pockets trying to pickpocket something !");
	  					}
	  				}
				}
				else
				{
    				SendClientMessage(playerid, COLOR_LIGHTRED, "The person is not next to you.");
				    return 1;
				}
			}
		}
		else
		{
  			SendClientMessage(playerid, COLOR_LIGHTRED, "(( The player is not connected )).");
	    	return 1;
		}
		return 1;
	}
	if(!strcmp(cmdtext, "/taximeter"))
    {
        if(PlayerInfo[playerid][Job]==5 && Taximetro[playerid]==0)
        {
            Taximetro[playerid]=5;
      		format(string, sizeof(string), "* %s turns on the taximeter.", NombreEx(playerid));
        	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
        }
        else if(Taximetro[playerid]!=0)
        {
      		format(string, sizeof(string), "* %s stops the taximeter.", NombreEx(playerid));
        	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
        	format(string, sizeof(string), "Final cost of the trip: $ %d.", Taximetro[playerid]);
        	ProxDetector(8.0, playerid, string, COLOR_LIGHTBLUE,COLOR_LIGHTBLUE,COLOR_LIGHTBLUE,COLOR_LIGHTBLUE,COLOR_LIGHTBLUE);
        	Taximetro[playerid]=0;
        }
   		return 1;
	}
	if(!strcmp(cmdtext, "/fish"))
	{
 		if(PlayerInfo[playerid][Job] == 6 && 44 <= GetPlayerVehicleID(playerid) <= 45)
     	{
     	    Pescando[playerid] = 1;
	        SetPlayerCheckpoint(playerid,2026.0967,-2851.7935,0.0314,3.5);
	        SendClientMessage(playerid, COLOR_YELLOW,"[RADAR] A gathering of fish has been detected, go to the marked area.");
     	}
	   	return 1;
	}
	if(!strcmp(cmdtext, "/smuggle"))
    {
        if(PlayerInfo[playerid][Faction] < 4)
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED,"You don't have connections in the black market.");
			return 1;
		}
        if(!PlayerToPoint(40, playerid, 2411.8665,-2547.5198,13.6517))
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED,"[Smuggler SMS] Come to Ocean Docks, close to where the fishermen work.");
			return 1;
		}
		if(PlayerInfo[playerid][Hand]!=0)
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED,"[Smuggler] Come with your hands empty to take my good products.");
			return 1;
		}
		if(GetPlayerMoney(playerid) < 50)
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED,"[Smuggler] Bring some money and then we will make our deals.");
			return 1;
		}
		ShowPlayerDialog(playerid,28, DIALOG_STYLE_LIST, "Black Market", "Marijuana seed - $50\nBundle of marijuana - $100\nBundle of cocaine - $200\nBox of 9mm - $500\nBox of Uzi - $750\nAK-47 - $900\nBox of 9mm clips - $250\nBox of Uzi clips - $500\nBox of AK-47 clips - $1000", "Buy", "Cancel deal");
   		return 1;
	}
   	if(!strcmp(cmdtext, "/dress"))
    {
        if(NegVw[playerid] == 3)
        {
        	SetPlayerSkin(playerid, PlayerInfo[playerid][Skin]);
        }
   		return 1;
	}
	if(!strcmp(cmdtext, "/fill"))
	{
		if(IsAtGasStation(playerid))
		{
		    if(GetPlayerMoney(playerid) < 1)
		    {
		        SendClientMessage(playerid, COLOR_LIGHTRED, "You don't have enough cash.");
		        return 1;
		    }
		    GameTextForPlayer(playerid,"~w~~n~~n~~n~~n~~n~~n~~n~~n~~n~Fueling Vehicle, please wait",2000,3);
			SetTimer("Fillup",RefuelWait,0);
			Refueling[playerid] = 1;
		}
		else
		{
			SendClientMessage(playerid,COLOR_GREY,"You're not at Idlewood Petrol Station.");
		}
    	return 1;
	}
	if(!strcmp(cmdtext, "/seefuel"))
	{
		if(gGas[playerid] == 0)
		{
			gGas[playerid] = 1;
			GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~g~Fuel Info on", 5000, 5);
			PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
		}
		else if(gGas[playerid] == 1)
		{
			gGas[playerid] = 0;
			GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~r~Fuel Info off", 5000, 5);
			PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
		}
		return 1;
	}
	if(!strcmp(cmdtext, "/hospital"))
	{
        if(paramedics == 1)
        {
            SendClientMessage(playerid, COLOR_GREY, "Paramedics are on the way, resist!");
            return 1;
        }
		if(PlayerInfo[playerid][Dead] == 1 && Hospital[playerid] == 1)
		{
		    format(string, sizeof(string), "* %s has been taken to hospital.", NombreEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN);
			printf("%s", string);
			Hospital[playerid] = 0;
			PlayerInfo[playerid][Dead] = 0;
			PlayerInfo[playerid][Bank] -= 500;
			TogglePlayerControllable(playerid, 0);
			SetPlayerVirtualWorld(playerid, 0);
			SetPlayerInterior(playerid,1);
			SetTimerEx("Descongelacion",1500,0,"i",playerid);
			SetPlayerHealth(playerid,50);
			CasaVw[playerid] = 0;
			SetPlayerPos(playerid,1975.6343,-1453.2069,499.1859);
		}
		return 1;
	}
	if(!strcmp(cmdtext, "/prison"))
	{
	    format(string, sizeof(string), "Sentence status: %d paydays.", PlayerInfo[playerid][Prison]);
		SendClientMessage(playerid, COLOR_RED, string);
		return 1;
	}
	if(!strcmp(cmdtext, "/getsandwich"))
	{
	    if(PlayerToPoint(3, playerid,1766.6803,-1527.8115,-13.3438))
		{
		    PlayerInfo[playerid][Hand] = 27;
   			PlayerInfo[playerid][HandAmount] = 5;
		    SendClientMessage(playerid, COLOR_YELLOW,"[Waiter] Enjoy the sandwich.");
		    ResetObject(playerid);
		}
		else
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED,"Go to the cafeteria.");
		}
		return 1;
	}
	if(!strcmp(cmdtext, "/getwater"))
	{
	    if(PlayerToPoint(3, playerid,1766.6803,-1527.8115,-13.3438))
		{
		    PlayerInfo[playerid][Hand] = 31;
   			PlayerInfo[playerid][HandAmount] = 5;
		    SendClientMessage(playerid, COLOR_YELLOW,"[Waiter] Enjoy the water.");
		    ResetObject(playerid);
		}
		else
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED,"Go to the cafeteria.");
		}
		return 1;
	}
	if(!strcmp(cmdtext, "/exam",true))
    {
 		if(!PlayerToPoint(1.0, playerid,1219.2954,-1812.5404,16.5938))
    	{
    	    SendClientMessage(playerid, COLOR_LIGHTRED, "Go to the public transport HQ to get the driving licence.");
	        return 1;
		}
		if(PlayerInfo[playerid][Licence] > 0)
    	{
    	    SendClientMessage(playerid, COLOR_LIGHTRED, "You already have the driving licence.");
			return 1;
		}
		if(pTest[playerid] != 0)
		{
		    SendClientMessage(playerid, COLOR_GREY, "You're already doing the exam.");
			return 1;
		}
		if(GetPlayerMoney(playerid) < 500)
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED, "You need 500 dollars.");
			return 1;
		}
		TogglePlayerControllable(playerid, 0);
		GameTextForPlayer(playerid, "~r~Read carefully",5000,3);
		DKT1(playerid);
		pTest[playerid] = 1;
		return 1;
	}
	if(!strcmp(cmdtext, "/repair"))
	{
	    if(PlayerToPoint(6, playerid,405.8781,-1724.5875,8.6603))
		{
		    if(GetPlayerState(playerid) == 2)
			{
			    if(GetPlayerMoney(playerid) > 1)
			    {
			        PlayerPlaySound(playerid,1133,0.0,0.0,0.0);
                	RepairVehicle(GetPlayerVehicleID(playerid));
                	GivePlayerMoney(playerid,-1500);
			    }
			}
		}
		else
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED,"You aren't at Santa Maria Beach Workshop.");
		}
		return 1;
	}
	if(!strcmp(cmdtext, "/toll"))
    {
        if(PlayerInfo[playerid][Bank] < 3)
        {
            SendClientMessage(playerid, COLOR_LIGHTRED,"You don't have enough money in your bank account.");
            return 1;
        }
        if(PlayerToPoint(2.5, playerid,68.8450,-1526.6504,4.8832))
		{
           	if(BloqueoPeajes == 1) { SendClientMessage(playerid, COLOR_LIGHTRED,"The tolls have been blocked by police."); return 1; }
			MoveDynamicObject(Puertapeaje1, 65.339996337891, -1529.5, 4.8000001907349+0.0001, 0.0001, 0, 0, 90);
			SetTimer("Cierrepeaje1", 11000, 0);
  			format(string, sizeof(string), "* %s uses her/his credit card and pays the toll.", NombreEx(playerid));
  			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
  			SendClientMessage(playerid, COLOR_ORANGE,"[Guard] The cost is 3 dollars, and you have ten seconds to pass.");
  			PlayerPlaySound(playerid, 1153, 1589.053344,-1638.123168,14.122960);
  			PlayerInfo[playerid][Bank] -= 3;
		}
		else if(PlayerToPoint(2.5, playerid,34.4336,-1537.2584,5.2364))
		{
            if(BloqueoPeajes == 1) { SendClientMessage(playerid, COLOR_LIGHTRED,"The tolls have been blocked by police."); return 1; }
      		MoveDynamicObject(Puertapeaje2, 36.400001525879, -1533.8000488281, 5.0999999046326+0.0001, 0.0001, 0, 0, 270);
      		SetTimer("Cierrepeaje2", 11000, 0);
      		format(string, sizeof(string), "* %s uses her/his credit card and pays the toll.", NombreEx(playerid));
  			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
  			SendClientMessage(playerid, COLOR_ORANGE,"[Guard] The cost is 3 dollars, and you have ten seconds to pass.");
  			PlayerPlaySound(playerid, 1153, 1589.053344,-1638.123168,14.122960);
  			PlayerInfo[playerid][Bank] -= 3;
		}
		return 1;
	}
	if(!strcmp(cmdtext, "/blocktolls"))
	{
		if (PlayerInfo[playerid][Faction] != 1) return SendClientMessage(playerid, COLOR_LIGHTRED, "You don't have permission for that.");
  		if (BloqueoPeajes == 0)
  		{
  			BloqueoPeajes = 1;
		  	format(string, sizeof(string), "[Police Station] The tolls have been blocked by %s.", NombreEx(playerid));
		  	SendFamilyMessage(1, COLOR_BLUE, string);
  		}
  		else
  		{
 			BloqueoPeajes = 0;
		  	format(string, sizeof(string), "[Police Station] The tolls have been unblocked by %s.", NombreEx(playerid));
		  	SendFamilyMessage(1, COLOR_BLUE, string);
  		}
		return 1;
	}
	if(!strcmp(cmdtext, "/clock"))
	{
 		new mtext[20];
		new year, month,day;
		getdate(year, month, day);
		if(month == 1) { mtext = "January"; }
		else if(month == 2) { mtext = "February"; }
		else if(month == 3) { mtext = "March"; }
		else if(month == 4) { mtext = "April"; }
		else if(month == 5) { mtext = "May"; }
		else if(month == 6) { mtext = "June"; }
		else if(month == 7) { mtext = "July"; }
		else if(month == 8) { mtext = "August"; }
		else if(month == 9) { mtext = "September"; }
		else if(month == 10) { mtext = "October"; }
		else if(month == 11) { mtext = "November"; }
		else if(month == 12) { mtext = "December"; }
  		new hour,minuite,second;
		gettime(hour,minuite,second);
		FixHour(hour);
		hour = shifthour;
		GameTextForPlayer(playerid, string, 5000, 1);
        format(string, sizeof(string), "* %s looks at her/his clock.", NombreEx(playerid));
		ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		ApplyAnimation(playerid,"COP_AMBIENT","Coplook_watch",4.1,0,0,0,0,0);
		format(string, sizeof(string), "~y~%d %s~n~~g~|~w~%d:%d~g~|", day, mtext, hour, minuite);
		GameTextForPlayer(playerid, string, 5000, 1);
		return 1;
	}
	return SendClientMessage(playerid, COLOR_GREY, "(( Unknown command, check /help )).");
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
    if(1 <= PlayerInfo[playerid][Job] <= 2)
	{
	    DisablePlayerCheckpoint(playerid);
	}
	if(Repartiendo[playerid] < 0)
	{
	    DisablePlayerCheckpoint(playerid);
	}
	if(Repartiendo[playerid] > 0)
	{
	    new engine,lights,alarm,doors,bonnet,boot,objective;
    	GetVehicleParamsEx(Camion[playerid],engine,lights,alarm,doors,bonnet,boot,objective);
    	SetVehicleParamsEx(Camion[playerid],engine,lights,alarm,doors,bonnet,1,objective);
	}
    DisablePlayerSpeedCap(playerid);
	if(GetPlayerVehicleID(playerid) > 50)
	{
		GetVehiclePos(vehicleid,Float:vex,Float:vey,Float:vez); GetVehicleZAngle(vehicleid,Float:vea);
		new idreal = GetPlayerVehicleID(playerid);
		new cajon = idreal-51;
		new llave = Carros[cajon]-51;
		Vehicle[llave][Posicionx] = Float:vex;
		Vehicle[llave][Posiciony] = Float:vey;
		Vehicle[llave][Posicionz] = Float:vez;
		Vehicle[llave][Angulo] = Float:vea;
    }
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(newstate == PLAYER_STATE_ONFOOT)
	{
 		if(CarryingBox[playerid] == 1)
	  	{
	  		LoopingAnim(playerid, "CARRY", "crry_prtial",4.1,0,1,1,1,1);
	  	}
        return 1;
    }
    if(newstate == PLAYER_STATE_DRIVER)
    {
    	if(Bicicletas(GetPlayerVehicleID(playerid)))
    	{
    		SetPlayerSpeedCap(playerid, 0.24);
   		}
    }
    if(oldstate == PLAYER_STATE_DRIVER)
    {
    	DisablePlayerSpeedCap(playerid);
    }
    if(newstate == PLAYER_STATE_DRIVER)
   	{
    	if(Motor[GetPlayerVehicleID(playerid)] == 0)
     	{
      		if(Bicicletas(GetPlayerVehicleID(playerid)))
			{
		    	new veh = GetPlayerVehicleID(playerid);
       			new engine,lights,alarm,doors,bonnet,boot,objective;
          		GetVehicleParamsEx(veh,engine,lights,alarm,doors,bonnet,boot,objective);
            	SetVehicleParamsEx(veh,VEHICLE_PARAMS_ON,lights,alarm,doors,bonnet,boot,objective);
            }
            else
            {
     			SendClientMessage(playerid, COLOR_LIGHTRED,"* The /engine of the vehicle is off.");
       			new veh = GetPlayerVehicleID(playerid);
          		new engine,lights,alarm,doors,bonnet,boot,objective;
            	GetVehicleParamsEx(veh,engine,lights,alarm,doors,bonnet,boot,objective);
             	SetVehicleParamsEx(veh,VEHICLE_PARAMS_OFF,lights,alarm,doors,bonnet,boot,objective);
        	}
		 }
		 else if(Motor[GetPlayerVehicleID(playerid)] == 1)
		 {
   			SendClientMessage(playerid, COLOR_LIGHTYELLOW,"* The engine of the vehicle is on.");
		    new veh = GetPlayerVehicleID(playerid);
      		new engine,lights,alarm,doors,bonnet,boot,objective;
        	GetVehicleParamsEx(veh,engine,lights,alarm,doors,bonnet,boot,objective);
         	SetVehicleParamsEx(veh,VEHICLE_PARAMS_ON,lights,alarm,doors,bonnet,boot,objective);
		 }
	}
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
    if(PlayerInfo[playerid][Faction]==1 || PlayerInfo[playerid][Faction]==2 || PlayerInfo[playerid][Faction]==3)
    {
    	DisablePlayerCheckpoint(playerid);
    }
    else if(PlayerInfo[playerid][Job] == 1)
    {
    	DisablePlayerCheckpoint(playerid);
    	PlayerInfo[playerid][Bank] += 30;
    	GameTextForPlayer(playerid, "~w~You earn $30",3500,3);
    	new randomss;
    	randomss = random(sizeof(PuntosGranja));
    	SetPlayerCheckpoint(playerid, PuntosGranja[randomss][0], PuntosGranja[randomss][1], PuntosGranja[randomss][2], 5.0);
    }
    else if(PlayerInfo[playerid][Job] == 2)
    {
        DisablePlayerCheckpoint(playerid);
        TogglePlayerControllable(playerid, 0);
        SetTimerEx("Descongelacion",2000,0,"i",playerid);
        if(Contenedor[playerid]==1)
        {
            SetPlayerCheckpoint(playerid,2269.2725,-1748.7869,13.9284,3.0);
            Contenedor[playerid]=2;
            DestroyDynamicObject(basuraUno);
            return 1;
		}
		else if(Contenedor[playerid] == 2)
        {
            SetPlayerCheckpoint(playerid,2631.5293,-1932.5620,13.9273,3.0);
            Contenedor[playerid]=3;
            DestroyDynamicObject(basuraDos);
            return 1;
		}
		else if(Contenedor[playerid] == 3)
        {
            Contenedor[playerid]=0;
            DestroyDynamicObject(basuraTres);
            PlayerInfo[playerid][Bank]+=500;
    		GameTextForPlayer(playerid, "~w~You earn $500",3500,3);
    		SendClientMessage(playerid, COLOR_YELLOW, "[SMS] You have received $500 in your bank account.");
            return 1;
		}
    	PlayerInfo[playerid][Bank]+=600;
    	GameTextForPlayer(playerid, "~w~You earn $600",3500,3);
    	SendClientMessage(playerid, COLOR_YELLOW, "[SMS] You have received $600 in your bank account.");
        DestroyDynamicObject(basuraSuelo);
    }
    else if(PlayerInfo[playerid][Job] == 3 && Repartiendo[playerid] > 0)
    {
        if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT)
 		{
 		    SendClientMessage(playerid, COLOR_LIGHTRED,"Get out of the lorry and /take the merchandise from the boot.");
 		    return 1;
 		}
 		if(CarryingBox[playerid] == 0)
 		{
 		    SendClientMessage(playerid, COLOR_LIGHTRED,"You have to /take the merchandise from the lorry's boot.");
 		    return 1;
 		}
    	DisablePlayerCheckpoint(playerid);
    	new engine,lights,alarm,doors,bonnet,boot,objective;
    	GetVehicleParamsEx(Camion[playerid],engine,lights,alarm,doors,bonnet,boot,objective);
    	SetVehicleParamsEx(Camion[playerid],engine,lights,alarm,doors,bonnet,0,objective);
    	PlayerInfo[playerid][Bank]+=900;
    	GameTextForPlayer(playerid, "~w~You earn $900",3500,3);
		new entregados = 100-Business[Repartiendo[playerid]][Products];
		new string[256];
		format(string, sizeof(string),"Box with %d products has been delivered to the business %s.",entregados,Business[Repartiendo[playerid]][Description]);
		SendClientMessage(playerid, COLOR_LIGHTGREEN, string);
		Business[Repartiendo[playerid]][Products]=100;
		Business[Repartiendo[playerid]][Money]-=entregados;
		Repartiendo[playerid]=0;
		CarryingBox[playerid]=0;
		Camion[playerid] = 0;
		LoopingAnim(playerid, "CARRY", "putdwn105",4.1,0,0,0,0,0);
		PlayerInfo[playerid][Hand] = 0;
   		PlayerInfo[playerid][HandAmount] = 0;
   		RemovePlayerAttachedObject(playerid, 0);
   		SendClientMessage(playerid, COLOR_YELLOW, "[SMS] You have received $900 in your bank account.");
    }
    else if(Repartiendo[playerid]==-1)
    {
        DisablePlayerCheckpoint(playerid);
        SetPlayerCheckpoint(playerid,1918.6857,-1794.1707,14.3826,4.0);
        Repartiendo[playerid]=-2;
        GameTextForPlayer(playerid, "~w~Go to Idlewood gas station",3500,3);
    }
    else if(Repartiendo[playerid]==-2)
    {
        DisablePlayerCheckpoint(playerid);
        new Float:X, Float:Y, Float:Z;
		GetVehiclePos(38, X, Y, Z);
		if(IsPlayerInRangeOfPoint(playerid, 15.0, X, Y, Z))
		{
        	Repartiendo[playerid]=0;
        	PlayerInfo[playerid][Bank]+=200;
        	GameTextForPlayer(playerid, "~w~You earn $200",3500,3);
        	SendClientMessage(playerid, COLOR_YELLOW, "[SMS] You have received $200 in your bank account.");
        	SetVehicleToRespawn(38);
		}
		else
		{
		    Repartiendo[playerid]=0;
		    SendClientMessage(playerid, COLOR_LIGHTRED,"[Boss] You have not brought the gasoline can.");
		}
    }
    else if(PlayerInfo[playerid][Job]==4)
    {
        if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT)
 		{
            SendClientMessage(playerid, COLOR_LIGHTRED,"Ring the doorbell on foot, don't be crazy.");
            return 1;
        }
        if(PlayerInfo[playerid][Hand] != 29)
        {
            SendClientMessage(playerid, COLOR_LIGHTRED,"Where is the pizza?");
            return 1;
        }
    	DisablePlayerCheckpoint(playerid);
    	GameTextForPlayer(playerid, "~w~You earn $200",3500,3);
		GivePlayerMoney(playerid,210);
		SendClientMessage(playerid, COLOR_GREEN,"Pizza delivered to the customer. 200 dollars earned.");
		PlayerInfo[playerid][Hand] = 0;
   		PlayerInfo[playerid][HandAmount] = 0;
   		RemovePlayerAttachedObject(playerid, 0);
   		LoopingAnim(playerid, "CARRY", "putdwn105",4.1,0,0,0,0,0);
    }
    else if(PlayerInfo[playerid][Job] == 5)
    {
        DisablePlayerCheckpoint(playerid);
        TogglePlayerControllable(playerid, 0);
        SetTimerEx("Descongelacion",2000,0,"i",playerid);
        if(Autobus[playerid] == 1)
        {
            Autobus[playerid]=2;
            SetPlayerCheckpoint(playerid,1966.4634,-2047.8884,13.5810,3.0);
        }
        else if(Autobus[playerid] == 2)
        {
            Autobus[playerid]=3;
            SetPlayerCheckpoint(playerid,2090.4238,-1770.1887,13.4901,3.0);
        }
        else if(Autobus[playerid] == 3)
        {
            Autobus[playerid]=4;
            SetPlayerCheckpoint(playerid,2074.4016,-1181.6238,23.7669,3.0);
        }
        else if(Autobus[playerid] == 4)
        {
            Autobus[playerid]=5;
            SetPlayerCheckpoint(playerid,1501.5388,-1031.9015,23.7445,3.0);
        }
        else if(Autobus[playerid] == 5)
        {
            Autobus[playerid]=6;
            SetPlayerCheckpoint(playerid,935.9325,-1137.3654,23.7833,3.0);
        }
        else if(Autobus[playerid] == 6)
        {
            Autobus[playerid]=7;
            SetPlayerCheckpoint(playerid,570.5420,-1224.5995,17.5491,3.0);
        }
        else if(Autobus[playerid] == 7)
        {
            Autobus[playerid]=8;
            SetPlayerCheckpoint(playerid,526.7953,-1553.7806,15.5235,3.0);
        }
        else if(Autobus[playerid] == 8)
        {
            Autobus[playerid]=9;
            SetPlayerCheckpoint(playerid,655.3845,-1756.4536,13.5305,3.0);
        }
        else if(Autobus[playerid] == 9)
        {
            Autobus[playerid]=0;
            PlayerInfo[playerid][Bank]+=800;
        	GameTextForPlayer(playerid, "~w~You earn $800",3500,3);
        	SendClientMessage(playerid, COLOR_WHITE, "[Boss] Take the bus back to the terminal.");
        	SendClientMessage(playerid, COLOR_YELLOW, "[SMS] You have received $800 in your bank account.");
        }
    }
    else if(PlayerInfo[playerid][Job]==8 && PlayerInfo[playerid][CriminalSkill]==0)
    {
        if(PlayerInfo[playerid][Hand]!=13)
        {
            SendClientMessage(playerid, COLOR_LIGHTRED,"You need a Molotov cocktail in your hand.");
            return 1;
        }
        if(GetPlayerAmmo(playerid)!=1)
        {
            SendClientMessage(playerid, COLOR_LIGHTRED,"Come with the Molotov cocktail in your hand.");
            return 1;
        }
        DisablePlayerCheckpoint(playerid);
        ResetPlayerWeapons(playerid);
        GameTextForPlayer(playerid, "~w~Run away",3500,3);
        ProxDetector(50.0, playerid, "* Somebody threw a Molotov cocktail at a store!", COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN);
        SendClientMessage(playerid, COLOR_LIGHTYELLOW, "[Mobster SMS] Find a hideout, take a rest and let me know when you're up for another mission.");
        PlayerInfo[playerid][Hand] = 0;
   		PlayerInfo[playerid][HandAmount] = 0;
   		RemovePlayerAttachedObject(playerid, 0);
        fuegoUno = CreateObject(18694, 1833.4407,-1842.6156,12.5781, 0, 0, 180);
		fuegoDos = CreateObject(18688, 1832.3695,-1837.6858,12.5781, 0, 0, 180);
		humoUno = CreateObject(18691, 1833.4407,-1842.6156,15.5, 0, 0, 180);
		humoDos = CreateObject(18689, 1833.6257,-1851.5488,12.3897, 0, 0, 180);
		PlayerInfo[playerid][CriminalSkill]=1;
		Business[4][Products] = 0;
		Business[4][Money] += 200;
		SendAlertMessage(3,COLOR_BLUE,"[Headquarters] A fire has been reported in Unity Station.",1833.4407,-1842.6156,13.5781);
    	SendAlertMessage(2,COLOR_BLUE,"[Headquarters] A fire has been reported in Unity Station, all firemen are required there.",1833.4407,-1842.6156,13.5781);
    	SendAlertMessage(1,COLOR_BLUE,"[Police Station] A fire has been reported in Unity Station, assistance for firemen is required.",1833.4407,-1842.6156,13.5781);
    	delito = 1;
    }
    else if(PlayerInfo[playerid][Job]==8 && Mision[playerid]==1)
    {
        DisablePlayerCheckpoint(playerid);
        LoopingAnim(playerid,"BOMBER","BOM_Plant",4.1,0,0,0,0,0);
        Mision[playerid]=0;
        GivePlayerMoney(playerid, 1200);
        GameTextForPlayer(playerid, "~w~Bag delivered",3500,3);
        RemovePlayerAttachedObject(playerid, 3);
        SendClientMessage(playerid, 0xFFFFFFFF, "{FFFFFF}[Mobster] Good job, here you have your share, {0D9E3D}1200 {FFFFFF}dollars.");
        if(PlayerInfo[playerid][CriminalSkill]==1)
        {
            PlayerInfo[playerid][CriminalSkill]=2;
		}
    }
    else if(Mision[playerid] == 2)
    {
        if(PlayerInfo[playerid][Hand]!=0)
        {
            SendClientMessage(playerid, COLOR_LIGHTRED,"Come with your hands empty in order to take the pistol.");
            return 1;
        }
        if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT)
 		{
 		    SendClientMessage(playerid, COLOR_LIGHTRED,"Get outta the vehicle to take the pistol.");
 		    return 1;
 		}
        Mision[playerid]=0;
        DisablePlayerCheckpoint(playerid);
        PlayerInfo[playerid][Hand]=1;
		PlayerInfo[playerid][HandAmount]=17;
		LoopingAnim(playerid,"BOMBER","BOM_Plant",4.1,0,0,0,0,0);
		PlayerInfo[playerid][CriminalSkill]=3;
		GameTextForPlayer(playerid, "~w~You have found a 9mm pistol",3500,3);
		ResetObject(playerid);
    }
    else if(Mision[playerid] > 50)
    {
        new Float:X, Float:Y, Float:Z;
        GetVehiclePos(Mision[playerid], X, Y, Z);
		if(IsPlayerInRangeOfPoint(playerid, 15.0, X, Y, Z))
		{
	        DisablePlayerCheckpoint(playerid);
	        GivePlayerMoney(playerid, 500);
	        GameTextForPlayer(playerid, "~w~You earn $500",3500,3);
	        SendClientMessage(playerid, COLOR_LIGHTYELLOW,"[Mobster] Good job bringing the car. Take your 500 dollars.");
	        SendClientMessage(playerid, COLOR_LIGHTYELLOW,"[Mobster] I will steal some parts and leave the vehicle where it was, before the owner realises.");
	        DestroyVehicle(GetPlayerVehicleID(playerid));
            for(new i; i < 20; i++)
			{
			    if(i+51 == Mision[playerid])
			    {
			        Vehicle[Carros[i]-51][Tiempo]=5;
					Carros[i]=0;
			    }
			}
			Mision[playerid]=0;
			if(PlayerInfo[playerid][CriminalSkill]==3)
			{
			    PlayerInfo[playerid][CriminalSkill]=4;
				SendClientMessage(playerid, COLOR_GREEN,"(( Your skill of criminal has improved. Now you can /pickpocket people )).");
				SendClientMessage(playerid, COLOR_WHITE,"[Mobster] From now on, all the missions will be stealing cars.");
			}
		}
		else
		{
		    SendClientMessage(playerid, COLOR_LIGHTGREEN,"[Mobster] Bring the vehicle.");
		}
	}
	else if((PlayerInfo[playerid][Job] == 6) && (Pescando[playerid] > 0) && (44 <= GetPlayerVehicleID(playerid) <= 45))
	{
	    DisablePlayerCheckpoint(playerid);
	    if(Pescando[playerid] == 1)
	    {
		    SetPlayerCheckpoint(playerid, 942.7733,-2436.7625,-0.5203, 3.5);
		    GameTextForPlayer(playerid, "~w~Capturing fish with the net",3500,3);
		    Pescando[playerid] = 2;
		}
		else if(Pescando[playerid] == 2)
		{
		    SetPlayerCheckpoint(playerid, 387.7495,-2130.2166,-0.2432, 3.5);
		    GameTextForPlayer(playerid, "~w~Capturing fish with the net",3500,3);
		    Pescando[playerid] = 3;
		}
		else if(Pescando[playerid] == 3)
		{
		    SetPlayerCheckpoint(playerid, 27.7710,-1605.9048,-0.3555, 3.5);
		    GameTextForPlayer(playerid, "~w~Capturing fish with the net",3500,3);
		    Pescando[playerid] = 4;
		}
		else if(Pescando[playerid] == 4)
		{
		    SetPlayerCheckpoint(playerid, 2297.4734,-2562.9929,-0.2465, 3.5);
		    GameTextForPlayer(playerid, "~w~Capturing fish with the net",3500,3);
		    Pescando[playerid] = 5;
		}
		else if(Pescando[playerid] == 5)
		{
		    GivePlayerMoney(playerid, 900);
		    SendClientMessage(playerid, 0xFFFFFFFF, "{FFFFFF}[Port Worker] Good job bringing me all this fish, take this envelope of ${0D9E3D}900{FFFFFF}.");
		}
	}
	else if(Autobus[playerid]>0)
	{
	    DisablePlayerCheckpoint(playerid);
	}
    return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

/*public OnPlayerRequestSpawn(playerid)
{
	return 1;
}*/

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    //new string[128];
	if(newkeys == KEY_SECONDARY_ATTACK)
    {
	    new Float:cx, Float:cy, Float:cz;
		GetPlayerPos(playerid, cx, cy, cz);
	    if(GetPlayerState(playerid) == 1)
	    {
			if(PlayerToPointStripped(1, playerid,1797.8315,-1578.8566,14.0901, cx,cy,cz))
			{
			    SetPlayerPos(playerid, 1810.7233,-1550.4980,-6.9851);
			    GameTextForPlayer(playerid, "~w~federal prison",5000,1);
			    SetPlayerInterior(playerid,0);
			    SetPlayerVirtualWorld(playerid, 1);
			    SetPlayerFacingAngle(playerid, 0);
			}
			else if(PlayerToPointStripped(1, playerid,1763.7023,-1538.8535,-13.3438, cx,cy,cz))
			{
			    SetPlayerPos(playerid, 1772.1095,-1548.1125,9.9063);
			    GameTextForPlayer(playerid, "~w~playground",5000,1);
			    SetPlayerInterior(playerid,0);
			    SetPlayerVirtualWorld(playerid, 0);
			}
			else if(PlayerToPointStripped(1, playerid,1772.1095,-1548.1125,9.9063, cx,cy,cz))
			{
			    SetPlayerPos(playerid, 1763.7023,-1538.8535,-13.3438);
			    GameTextForPlayer(playerid, "~w~federal prison",5000,1);
			    SetPlayerInterior(playerid,0);
			    SetPlayerVirtualWorld(playerid, 1);
			}
			else if(PlayerToPointStripped(1, playerid,1810.7233,-1550.4980,-6.9851, cx,cy,cz))
			{
			    SetPlayerPos(playerid, 1797.8315,-1578.8566,14.0901);
			    GameTextForPlayer(playerid, "~w~Los Santos",5000,1);
			    SetPlayerInterior(playerid,0);
			    SetPlayerVirtualWorld(playerid, 0);
			    SetPlayerFacingAngle(playerid, 270);
			}
			else if(PlayerToPointStripped(1, playerid,1564.7402,-1666.0062,28.3956, cx,cy,cz))
			{
			    SetPlayerPos(playerid, 246.4406,87.4276,1003.6406);
			    GameTextForPlayer(playerid, "~w~police station",5000,1);
			    SetPlayerInterior(playerid,6);
			}
			else if(PlayerToPointStripped(1, playerid,1568.6133,-1689.9739,6.2188, cx,cy,cz))
			{
			    SetPlayerPos(playerid, 246.4406,87.4276,1003.6406);
			    GameTextForPlayer(playerid, "~w~police station",5000,1);
			    SetPlayerInterior(playerid,6);
			}
			else if(PlayerToPointStripped(1, playerid,1163.2063,-1329.7548,31.4863, cx,cy,cz))
			{
			    SetPlayerPos(playerid, 1926.3743,-1509.0028,499.1879);
			    GameTextForPlayer(playerid, "~w~hospital",5000,1);
			    SetPlayerInterior(playerid,1);
			    TogglePlayerControllable(playerid, 0);
       			SetTimerEx("Descongelacion",1000,0,"i",playerid);
			}
		}
	}
	if(newkeys == KEY_FIRE)
   	{
    	if(PlayerInfo[playerid][Hand]==13)
    	{
             PlayerInfo[playerid][Hand] = 0;
             PlayerInfo[playerid][HandAmount] = 0;
			 ProxDetector(50.0, playerid, "* Somebody just threw a Molotov cocktail!", COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN,COLOR_LIGHTGREEN);
			 return 1;
    	}
    	if(CarryingBox[playerid] == 1)
		{
	  		LoopingAnim(playerid, "CARRY", "crry_prtial",4.1,0,1,1,1,1);
	  		return 1;
  		}
   	}
	if(newkeys == KEY_SPRINT)
	{
      	if(PlayerInfo[playerid][Dead] != 0)
   		{
       		TogglePlayerControllable(playerid, 0);
       		ApplyAnimation(playerid, "CRACK", "crckdeth2", 4.0, 1, 0, 0, 0, 0);
       		SetPlayerHealth(playerid, 20.0);
       		LoopingAnim(playerid, "CRACK", "crckdeth2", 4.0, 1, 0, 0, 0, 0);
       		return 1;
   		}
	  	if(CarryingBox[playerid] == 1)
	  	{
	  		new Float:cx, Float:cy, Float:cz;
  	  		GetPlayerPos(playerid, cx, cy, cz);
	  		SetPlayerPos(playerid, cx,  cy, cz);
	  		LoopingAnim(playerid, "CARRY", "crry_prtial",4.1,0,1,1,1,1);
	  		return 1;
		}
		if(DoingAnimation[playerid] == 1)
        {
            DoingAnimation[playerid] = 0;
            ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0);
        }
    }
   	if(newkeys == KEY_JUMP)
    {
        if(PlayerInfo[playerid][Dead] != 0)
   		{
       		TogglePlayerControllable(playerid, 0);
       		ApplyAnimation(playerid, "CRACK", "crckdeth2", 4.0, 1, 0, 0, 0, 0);
       		SetPlayerHealth(playerid, 20.0);
       		LoopingAnim(playerid, "CRACK", "crckdeth2", 4.0, 1, 0, 0, 0, 0);
       		return 1;
   		}
		if(CarryingBox[playerid] == 1)
	  	{
	  		new Float:cx, Float:cy, Float:cz;
  	  		GetPlayerPos(playerid, cx, cy, cz);
	  		SetPlayerPos(playerid, cx,  cy, cz);
	  		LoopingAnim(playerid, "CARRY", "crry_prtial",4.1,0,1,1,1,1);
	  		return 1;
	  	}
    }
	if(newkeys == KEY_SECONDARY_ATTACK)
   	{
    	if(IsPlayerConnected(playerid))
		{
			for(new i = 0; i < sizeof(House); i++)
			{
				if (PlayerToPoint(1, playerid,House[i][Entrancex], House[i][Entrancey], House[i][Entrancez]))
				{
                    if(House[i][Locked] == 0)
					{
						SetPlayerPos(playerid,House[i][Exitx],House[i][Exity],House[i][Exitz]);
						SetPlayerInterior(playerid, House[i][Interior]);
						SetPlayerVirtualWorld(playerid,i);
      					CasaVw[playerid]=i;
      					TogglePlayerControllable(playerid,0);
      					SetTimerEx("Descongelacion",1000,0,"i",playerid);
					}
					else
					{
						GameTextForPlayer(playerid, "~r~Closed", 5000, 1);
					}
		  		}
			}
		}
   	}
  	if(newkeys == KEY_SECONDARY_ATTACK)
   	{
        if(IsPlayerConnected(playerid))
		{
			for(new i = 0; i < sizeof(House); i++)
			{
				if (PlayerToPoint(3, playerid,House[i][Exitx], House[i][Exity], House[i][Exitz]))
				{
				    new vw = CasaVw[playerid];
                    if(House[vw][Locked] == 0)
					{
						SetPlayerPos(playerid,House[vw][Entrancex],House[vw][Entrancey],House[vw][Entrancez]);
						SetPlayerInterior(playerid, 0);
						SetPlayerVirtualWorld(playerid,0);
						TogglePlayerControllable(playerid,1);
					}
					else
					{
						GameTextForPlayer(playerid, "~r~Closed", 5000, 1);
					}
				}
			}
		}
   	}
	if(newkeys == KEY_SECONDARY_ATTACK)
   	{
        if(IsPlayerConnected(playerid))
		{
			for(new i = 0; i < sizeof(Business); i++)
			{
				if (PlayerToPoint(1, playerid,Business[i][Entrancex], Business[i][Entrancey], Business[i][Entrancez]))
				{
					SetPlayerPos(playerid,Business[i][Exitx],Business[i][Exity],Business[i][Exitz]);
					SetPlayerInterior(playerid, Business[i][Interior]);
					SetPlayerVirtualWorld(playerid,i);
					NegVw[playerid]=i;
			  	}
			}
		}
   	}
   	if(newkeys == KEY_SECONDARY_ATTACK)
   	{
    	if(IsPlayerConnected(playerid))
		{
			for(new i = 0; i < sizeof(Business); i++)
			{
				if(PlayerToPoint(1, playerid,Business[i][Exitx], Business[i][Exity], Business[i][Exitz]))
				{
				    new vw = NegVw[playerid];
					SetPlayerPos(playerid,Business[vw][Entrancex],Business[vw][Entrancey],Business[vw][Entrancez]);
					SetPlayerInterior(playerid, 0);
					SetPlayerVirtualWorld(playerid,0);
				}
			}
		}
   	}
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    new sendername[MAX_PLAYER_NAME];
	new string[128];
    if(dialogid == 1) // Registering.
	{
 		if(response)
	  	{
    		if(strlen(inputtext))
		    {
		    	GetPlayerName(playerid, sendername, sizeof(sendername));
				format(string, sizeof(string), "users/%s.ini", sendername);
				new File: hFile = fopen(string, io_read);
				if (hFile)
				{
					fclose(hFile);
					return 1;
				}
				new tmppass[64];
				strmid(tmppass, inputtext, 0, strlen(inputtext), 255);
				ShowPlayerDialog(playerid, 2, DIALOG_STYLE_MSGBOX, "Sex", "What is your sex?", "Male", "Female");
				SaveAccount(playerid, tmppass);
			}
			else
			{
 				new regstring[128];
				new regname[64];
				GetPlayerName(playerid,regname,sizeof(regname));
				format(regstring,sizeof(regstring),"%s.\n\nWrite a password:",regname);
                ShowPlayerDialog(playerid,1,DIALOG_STYLE_INPUT,"Register",regstring,"Register","Cancel");
			}
		}
		else { Kick(playerid); }
  	}
  	else if(dialogid == 2)
  	{
  	    if(response)
	  	{
    		PlayerInfo[playerid][Sex] = 1;
		    SendClientMessage(playerid, COLOR_LIGHTBLUE, "(( Sex: male )).");
		    ShowPlayerDialog(playerid, 3, DIALOG_STYLE_INPUT, "Age", "Select the age:", "Send", "");
		    return 0;
	  	}
	  	else
	  	{
    		PlayerInfo[playerid][Sex] = 2;
		    SendClientMessage(playerid, COLOR_LIGHTBLUE, "(( Sex: female )).");
		    ShowPlayerDialog(playerid, 3, DIALOG_STYLE_INPUT, "Age", "Select the age:", "Send", "");
		    return 0;
	  	}
  	}
  	else if(dialogid == 3)
  	{
  	    PlayerInfo[playerid][Age] = strval(inputtext);
	  	if(PlayerInfo[playerid][Age] > 100 || PlayerInfo[playerid][Age] < 18)
	  	{
    		SendClientMessage(playerid, COLOR_LIGHTRED, "(( Age must be between the range 18 and 100 )).");
      		ShowPlayerDialog(playerid, 3, DIALOG_STYLE_INPUT, "Age", "Select the age:", "Send", "");
	  	}
	  	else
	  	{
	  	    SaveAccount(playerid, PlayerInfo[playerid][Password]);
	  	    PlayerInfo[playerid][Admin] = -1;
	  	    TogglePlayerSpectating(playerid, 0);
	  	    SetSpawnInfo(playerid, 0, 26, 1642.4110, -2335.0168, -2.6797, 270, 0,0,0,0,0,0);
			SpawnPlayer(playerid);
			SendClientMessage(playerid, COLOR_LIGHTBLUE, "(( Congratulations, account registered successfully, type /help )).");
        	SendClientMessage(playerid, 0xFFFFFFFF, "{FFFFFF}[Steward] You can ask for a {FF00FF}/taxi {FFFFFF}using the phone box right there. Taxis are cheap.");
			LoginAccount(playerid, PlayerInfo[playerid][Password]);
			GivePlayerMoney(playerid,1000);
	  	}
  	}
  	else if(dialogid == 4)
	{
 		if(response)
	  	{
		    if(strlen(inputtext))
		    {
		        TogglePlayerSpectating(playerid, 0);
	  	    	SetSpawnInfo(playerid, 0,
		  			PlayerInfo[playerid][Skin],
				  	PlayerInfo[playerid][Pos_x],
				  	PlayerInfo[playerid][Pos_y],
				  	PlayerInfo[playerid][Pos_z], 90, 0,0,0,0,0,0);
				SpawnPlayer(playerid);
                new tmppass[64];
				strmid(tmppass, inputtext, 0, strlen(inputtext), 255);
				LoginAccount(playerid,tmppass);
			}
			else { Kick(playerid); }
	  	}
	  	else { Kick(playerid); }
    }
    else if(dialogid == 5)
    {
        PlayerInfo[playerid][Hand] = strval(inputtext);
        ShowPlayerDialog(playerid, 6, DIALOG_STYLE_INPUT, "Object amount", "Amount:", "Select", "");
    }
    else if(dialogid == 6)
    {
        PlayerInfo[playerid][HandAmount] = strval(inputtext);
        ResetObject(playerid);
    }
    else if(dialogid == 7)
    {
    
    }
	else if(dialogid == 8)
  	{
   		if(response)
	  	{
    		if(PlayerInfo[playerid][Hand] != 0)
            {
            	SendClientMessage(playerid, COLOR_LIGHTRED, "You have the hands busy and cannot take anything from your pockets.");
            	return 1;
            }
            switch(listitem)
            {
				case 0: {
                    PlayerInfo[playerid][Hand]=PlayerInfo[playerid][One];
	     			PlayerInfo[playerid][HandAmount]=PlayerInfo[playerid][OneAmount];
	     			PlayerInfo[playerid][One]=0;
					PlayerInfo[playerid][OneAmount]=0;
				}
				case 1: {
                    PlayerInfo[playerid][Hand]=PlayerInfo[playerid][Two];
	     			PlayerInfo[playerid][HandAmount]=PlayerInfo[playerid][TwoAmount];
	     			PlayerInfo[playerid][Two]=0;
					PlayerInfo[playerid][TwoAmount]=0;
				}
				case 2: {
                    PlayerInfo[playerid][Hand]=PlayerInfo[playerid][Three];
	     			PlayerInfo[playerid][HandAmount]=PlayerInfo[playerid][ThreeAmount];
	     			PlayerInfo[playerid][Three]=0;
					PlayerInfo[playerid][ThreeAmount]=0;
				}
				case 3: {
                    PlayerInfo[playerid][Hand]=PlayerInfo[playerid][Four];
	     			PlayerInfo[playerid][HandAmount]=PlayerInfo[playerid][FourAmount];
	     			PlayerInfo[playerid][Four]=0;
					PlayerInfo[playerid][FourAmount]=0;
				}
				case 4: {
                    PlayerInfo[playerid][Hand]=PlayerInfo[playerid][Five];
     				PlayerInfo[playerid][HandAmount]=PlayerInfo[playerid][FiveAmount];
     				PlayerInfo[playerid][Five]=0;
					PlayerInfo[playerid][FiveAmount]=0;
				}
			}
            format(string, sizeof(string),"%s taken from the pocket.",Obje[PlayerInfo[playerid][Hand]]);
			SendClientMessage(playerid, COLOR_GREY, string);
			ResetObject(playerid);
   		}
     	else
      	{
	  		TogglePlayerControllable(playerid, 1);
     	}
	}
	else if(dialogid == 14)
  	{
   		if(response)
	  	{
    		if(PlayerInfo[playerid][Hand] != 0)
            {
            	SendClientMessage(playerid, COLOR_LIGHTRED, "Your hands are busy and cannot take anything from the closet.");
            	return 1;
            }
            new key = PlayerInfo[playerid][HouseKey];
		  	if(listitem == 0)
		  	{
     			PlayerInfo[playerid][Hand]=House[key][Closet1];
     			PlayerInfo[playerid][HandAmount]=House[key][Amount1];
     			House[key][Closet1]=0;
				House[key][Amount1]=0;
       		}
         	if(listitem == 1)
          	{
		 		PlayerInfo[playerid][Hand]=House[key][Closet2];
     			PlayerInfo[playerid][HandAmount]=House[key][Amount2];
     			House[key][Closet2]=0;
				House[key][Amount2]=0;
     		}
	      	if(listitem == 2)
	      	{
        		PlayerInfo[playerid][Hand]=House[key][Closet3];
     			PlayerInfo[playerid][HandAmount]=House[key][Amount3];
     			House[key][Closet3]=0;
				House[key][Amount3]=0;
	      	}
            format(string, sizeof(string)," %s taken from the closet.",Obje[PlayerInfo[playerid][Hand]]);
			SendClientMessage(playerid, COLOR_GREY, string);
			ResetObject(playerid);
   		}
     	else
      	{
	  		TogglePlayerControllable(playerid, 1);
     	}
	}
	else if(dialogid == 15)
  	{
   		if(response)
	  	{
		  	if(listitem == 0)
		  	{
       		}
         	if(listitem == 1)
          	{
     		}
	      	if(listitem == 2)
	      	{
        		ShowPlayerDialog(playerid, 16, DIALOG_STYLE_INPUT, "Taking money...", "Amount:", "Press", "");
	      	}
	      	if(listitem == 3)
        	{
                ShowPlayerDialog(playerid, 17, DIALOG_STYLE_INPUT, "Depositing...", "Amount:", "Press", "");
	      	}
   		}
     	else
      	{
	  		TogglePlayerControllable(playerid, 1);
     	}
	}
	else if(dialogid == 16)
	{
	    new dinero = strval( inputtext ) ;
	    if(dinero>PlayerInfo[playerid][Bank])
	    {
	        SendClientMessage(playerid, COLOR_LIGHTRED, "[ATM] Error, you do NOT have that amount of money in your bank account.");
			return 1;
	    }
	    else if(dinero<1)
	    {
	        SendClientMessage(playerid, COLOR_LIGHTRED, "[ATM] Error, not valid amount.");
	        return 1;
	    }
	    else if(dinero<10000)
	    {
	        GivePlayerMoney(playerid, dinero);
	        PlayerInfo[playerid][Bank]-=dinero;
      		format(string, sizeof(string), "* %s takes some money from the ATM.", NombreEx(playerid));
        	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	        return 1;
	    }
	    else
	    {
	        SendClientMessage(playerid, COLOR_LIGHTRED, "[ATM] Error, select a lower amount.");
	        return 1;
	    }
	}
	else if(dialogid == 17)
	{
	    new dinero = strval( inputtext ) ;
	    if(dinero>GetPlayerMoney(playerid))
	    {
	        SendClientMessage(playerid, COLOR_LIGHTRED, "[ATM] Error, you have not reached the selected amount.");
	    }
	    else if(dinero<1)
	    {
	        SendClientMessage(playerid, COLOR_LIGHTRED, "[ATM] Error, wrong amount.");
	        return 1;
	    }
	    else if(dinero<10000)
	    {
	        GivePlayerMoney(playerid, -dinero);
	        PlayerInfo[playerid][Bank]+=dinero;
      		format(string, sizeof(string), "* %s deposits some money in the ATM.", NombreEx(playerid));
        	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	        return 1;
	    }
	    else
	    {
	        SendClientMessage(playerid, COLOR_LIGHTRED, "[ATM] Error, select a lower amount.");
	        return 1;
	    }
	}
	else if(dialogid == 18)
  	{
  	    new idgm=0;
      	for (new i = 0; i < 20; i++)
		{
		    if(Carros[i]==PlayerInfo[playerid][VehicleKey])
			{
			    idgm = i+51;
			}
		}
 		new engine,lights,alarm,doors,bonnet,boot,objective;
  		GetVehicleParamsEx(idgm,engine,lights,alarm,doors,bonnet,boot,objective);
   		SetVehicleParamsEx(idgm,engine,lights,alarm,doors,bonnet,0,objective);
   		if(response)
	  	{
			new idfichero = PlayerInfo[playerid][VehicleKey]-51;
		  	if(listitem == 0)
		  	{
		  	    if(PlayerInfo[playerid][Hand] !=0)
		  	    {
		  	        SendClientMessage(playerid, COLOR_LIGHTRED, "You have your hands busy.");
		  	        return 1;
		  	    }
		  	    if(Vehicle[idfichero][Maletero]!=0)
		  	    {
      				format(string, sizeof(string), "* %s takes something from the boot and closes it.", NombreEx(playerid));
        			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		  	    }
		  	    PlayerInfo[playerid][Hand]=Vehicle[idfichero][Maletero];
		  	    PlayerInfo[playerid][HandAmount]=Vehicle[idfichero][MaleteroCantidad];
		  	    ResetObject(playerid);
				Vehicle[idfichero][Maletero]=0;
				Vehicle[idfichero][MaleteroCantidad]=0;
       		}
       		if(listitem == 1)
	      	{
	      	}
         	if(listitem == 2)
          	{
          	    if(Vehicle[idfichero][Maletero]!=0 || PlayerInfo[playerid][Hand]==0) { return 1; }
          	 	new gunAmmo = GetPlayerAmmo(playerid);
	            Vehicle[idfichero][Maletero] = PlayerInfo[playerid][Hand];
	 			if(0 < PlayerInfo[playerid][Hand] < 14)
	 			{
    				Vehicle[idfichero][MaleteroCantidad] = gunAmmo;
 				}
	 			else
	 			{
    				Vehicle[idfichero][MaleteroCantidad] = PlayerInfo[playerid][HandAmount];
    			}
   				format(string, sizeof(string), "* %s puts something in the boot and closes it.", NombreEx(playerid));
    			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
          	    PlayerInfo[playerid][Hand] = 0;
   				PlayerInfo[playerid][HandAmount] = 0;
   				RemovePlayerAttachedObject(playerid, 0);
   				CarryingBox[playerid] = 0;
   				LoopingAnim(playerid, "CARRY", "putdwn105",4.1,0,0,0,0,0);
   				ResetPlayerWeapons(playerid);
     		}
	      	if(listitem == 3)
	      	{
	      	    if(Vehicle[idfichero][Maletero]==40)
				{
				    PlayerInfo[playerid][Hand]=1;
				    PlayerInfo[playerid][HandAmount]=17;
				    Vehicle[idfichero][MaleteroCantidad]-=1;
				}
				if(Vehicle[idfichero][Maletero]==41)
				{
				    PlayerInfo[playerid][Hand]=6;
				    PlayerInfo[playerid][HandAmount]=50;
				    Vehicle[idfichero][MaleteroCantidad]-=1;
				}
				if(Vehicle[idfichero][Maletero]==42)
				{
				    PlayerInfo[playerid][Hand]=18;
				    PlayerInfo[playerid][HandAmount]=17;
				    Vehicle[idfichero][MaleteroCantidad]-=1;
				}
				if(Vehicle[idfichero][Maletero]==43)
				{
				    PlayerInfo[playerid][Hand]=23;
				    PlayerInfo[playerid][HandAmount]=50;
				    Vehicle[idfichero][MaleteroCantidad]-=1;
				}
				if(Vehicle[idfichero][Maletero]==44)
				{
				    PlayerInfo[playerid][Hand]=25;
				    PlayerInfo[playerid][HandAmount]=30;
				    Vehicle[idfichero][MaleteroCantidad]-=1;
				}
				if(Vehicle[idfichero][Maletero]==45)
				{
				    PlayerInfo[playerid][Hand]=48;
				    PlayerInfo[playerid][HandAmount]=5;
				    Vehicle[idfichero][MaleteroCantidad]-=1;
				}
				if(Vehicle[idfichero][Maletero]==46)
				{
				    PlayerInfo[playerid][Hand]=49;
				    PlayerInfo[playerid][HandAmount]=1;
				    Vehicle[idfichero][MaleteroCantidad]-=1;
				}
				if(Vehicle[idfichero][MaleteroCantidad]<1)
				{
					Vehicle[idfichero][Maletero]=0;
				}
				ResetObject(playerid);
	      	}
   		}
	}
	else if(dialogid == 19) // Shop
	{
	    if(response)
	    {
	        if(Business[NegVw[playerid]][Products] < 1)
	        {
				SendClientMessage(playerid, COLOR_LIGHTRED, "The store ran out of products.");
				return 1;
   			}
			if(PlayerInfo[playerid][Hand] != 0)
			{
                SendClientMessage(playerid, COLOR_LIGHTRED, "The store ran out of products.");
				return 1;
			}
			new prices[][] = {
				{0, 0, 0, 0},
				{10, 30, 40, 50}, // Grocery: Bat 10, Briefcase 30, Camera 40, Phone 50.
				{2, 3, 5, 5}, // Gym: Water 2, Soda 3, Black box suit 5, White box suit 5.
				{2, 3, 4, 5}, // Bar: Water 2, Soda 3, Cigarette 4, Beer 5.
				{2, 3, 5, 10}, // Pizzeria: Water 2, Soda 3, Pizza slive 5, Pizza 10.
				{2, 10, 20, 50}, // Florist: Water 2, Knife 10, Shovel 20, Fertiliser 50.
				{0, 0, 0, 0}, // Clothes.
				{2, 10, 30, 50}, // Workshop: Water 2, Helmet 10, Picklock 30, Gasoline can 50.
				{2, 5, 5, 10}, // Betting:  Water 2, Beer 5, Dice 5, Lottery ticket 10.
				{0, 0, 0, 0}, // Petrol station.
				{200, 500, 1000, 1500} // Ammu-Nation: 9mm clip 200, Rifle clip 500, 9mm 1000, Rifle 1500.
			};
			new type = Business[NegVw[playerid]][Type];
			if(type == 1)
			{
			    switch(listitem)
			    {
			        case 0: { PlayerInfo[playerid][Hand] = 16; PlayerInfo[playerid][HandAmount] = 1; }
			        case 1: { PlayerInfo[playerid][Hand] = 35; PlayerInfo[playerid][HandAmount] = 0; }
			        case 2: { PlayerInfo[playerid][Hand] = 12; PlayerInfo[playerid][HandAmount] = 20; }
			        case 3:
					{
                        PlayerInfo[playerid][Hand] = 34; PlayerInfo[playerid][HandAmount] = 1;
		     			if(PlayerInfo[playerid][PhoneNumber] == 0)
		     			{
			     			PhoneNumberSystem[PhoneNumberCount]++;
			     			PlayerInfo[playerid][PhoneNumber] = PhoneNumberSystem[PhoneNumberCount];
	 						SavePhoneNumber();
						}
					}
			    }
			}
			else if(type == 2)
			{
			    switch(listitem)
			    {
			        case 0: { PlayerInfo[playerid][Hand]=31;PlayerInfo[playerid][HandAmount]=5; }
			        case 1: { PlayerInfo[playerid][Hand]=32;PlayerInfo[playerid][HandAmount]=5; }
			        case 2: {
			            SetPlayerSkin(playerid,80);
			            SendClientMessage(playerid, COLOR_WHITE, "[Gym assistant] You can /dress here whenever you want.");
		 			}
			        case 3: {
						SetPlayerSkin(playerid,81);
						SendClientMessage(playerid, COLOR_WHITE, "[Gym assistant] You can /dress here whenever you want.");
					}
			    }
			}
			else if(type == 3)
			{
                switch(listitem)
			    {
			        case 0: { PlayerInfo[playerid][Hand]=31;PlayerInfo[playerid][HandAmount]=5; }
			        case 1: { PlayerInfo[playerid][Hand]=32;PlayerInfo[playerid][HandAmount]=5; }
			        case 2: { PlayerInfo[playerid][Hand]=50;PlayerInfo[playerid][HandAmount]=5; }
			        case 3: { PlayerInfo[playerid][Hand]=33;PlayerInfo[playerid][HandAmount]=5; }
			    }
			}
			else if(type == 4)
			{
			    switch(listitem)
			    {
			        case 0: { PlayerInfo[playerid][Hand] = 31; PlayerInfo[playerid][HandAmount] = 5; }
			        case 1: { PlayerInfo[playerid][Hand] = 32; PlayerInfo[playerid][HandAmount] = 5; }
			        case 2: { PlayerInfo[playerid][Hand] = 30; PlayerInfo[playerid][HandAmount] = 5; }
			        case 3: { PlayerInfo[playerid][Hand] = 29; PlayerInfo[playerid][HandAmount] = 10; }
			    }
			}
			else if(type == 5)
			{
			    switch(listitem)
			    {
			        case 0: { PlayerInfo[playerid][Hand]=31;PlayerInfo[playerid][HandAmount]=5; }
			        case 1: { PlayerInfo[playerid][Hand]=14;PlayerInfo[playerid][HandAmount]=1; }
			        case 2: { PlayerInfo[playerid][Hand]=15;PlayerInfo[playerid][HandAmount]=1; }
			        case 3: { PlayerInfo[playerid][Hand]=39;PlayerInfo[playerid][HandAmount]=1; }
			    }
			}
			else if(type == 7)
			{
			    switch(listitem)
			    {
			        case 0: { PlayerInfo[playerid][Hand]=31;PlayerInfo[playerid][HandAmount]=5; }
			        case 1: { PlayerInfo[playerid][Hand]=38;PlayerInfo[playerid][HandAmount]=5; }
			        case 2: { PlayerInfo[playerid][Hand]=37;PlayerInfo[playerid][HandAmount]=5; }
			        case 3: { PlayerInfo[playerid][Hand]=36;PlayerInfo[playerid][HandAmount]=50; }
			    }
			}
			else if(type == 8)
			{
			    switch(listitem)
			    {
			        case 0: { PlayerInfo[playerid][Hand]=31;PlayerInfo[playerid][HandAmount]=5; }
			        case 1: { PlayerInfo[playerid][Hand]=32;PlayerInfo[playerid][HandAmount]=5; }
			        case 2: { PlayerInfo[playerid][Hand]=51;PlayerInfo[playerid][HandAmount]=1; }
			        case 3: { ShowPlayerDialog(playerid, 31, DIALOG_STYLE_INPUT, "Lottery", "Select a number between 1 and 50:", "Try luck", ""); }
			    }
			}
			else if(type == 10)
			{
			    switch(listitem)
			    {
			        case 0: { PlayerInfo[playerid][Hand] = 18; PlayerInfo[playerid][HandAmount] = 17; }
			        case 1: { PlayerInfo[playerid][Hand]=20; PlayerInfo[playerid][HandAmount]=5; }
			        case 2: { PlayerInfo[playerid][Hand]=1; PlayerInfo[playerid][HandAmount]=17; }
			        case 3: { PlayerInfo[playerid][Hand]=3; PlayerInfo[playerid][HandAmount]=5; }
			    }
			}
			Business[NegVw[playerid]][Products]--;
			Business[NegVw[playerid]][Money] += prices[type][listitem];
			GivePlayerMoney(playerid, -prices[type][listitem]);
			ResetObject(playerid);
	    }
	}
	else if(dialogid == 25)
	{
		if(response)
 		{
 		    if(Repartos[listitem] != 0)
 		    {
 		        SetPlayerCheckpoint(playerid,
		 			Business[Repartos[listitem]][Entrancex],
		 			Business[Repartos[listitem]][Entrancey],
		 			Business[Repartos[listitem]][Entrancez], 5.0);
		  	    Repartiendo[playerid] = Repartos[listitem];
				SendClientMessage(playerid, COLOR_YELLOW,"This lorry is full of goods, deliver them to the store pointed at on the radar.");
				Camion[playerid] = GetPlayerVehicleID(playerid);
				Repartos[listitem] = 0;
 		    }
 		    else
 		    {
 		        SendClientMessage(playerid, COLOR_LIGHTRED,"This order is not available.");
 		    }
   		}
	}
	else if(dialogid == 26)
  	{
   		if(response)
	  	{
	  	    new key = PlayerInfo[playerid][BusinessKey];
      		if(Business[key][Products] < 1) { SendClientMessage(playerid, COLOR_LIGHTRED, "No products left."); return 1; }
	  	    new llanta;
	  	    new idreal = GetPlayerVehicleID(playerid);
			new cajon = idreal-51;
			new llave = Carros[cajon]-51;
		  	switch(listitem)
			{
			    case 0: llanta = 1025; // offroad.
			    case 1: llanta = 1073; // shadow.
			    case 2: llanta = 1074; // mega.
			    case 3: llanta = 1075; // rimshine.
			    case 4: llanta = 1076; // wires.
			    case 5: llanta = 1077; // classic.
			    case 6: llanta = 1078; // twist.
			    case 7: llanta = 1079; // cutter.
			    case 8: llanta = 1080; // switch.
			    case 9: llanta = 1081; // grove.
			    case 10: llanta = 1082; // import.
			    case 11: llanta = 1083; // dollar.
			    case 12: llanta = 1084; // trance.
				case 13: llanta = 1085; // atomic.
				case 14: llanta = 1096; // ahab.
				case 15: llanta = 1097; // virtual.
				case 16: llanta = 1098; // access.
				case 17: // default.
				{
				    llanta = 0;
                    RemoveVehicleComponent(GetPlayerVehicleID(playerid),Vehicle[llave][Llanta]);
				}
			}
	      	if(llanta!=0)
	      	{
	      	    AddVehicleComponent(GetPlayerVehicleID(playerid),llanta);
	      	}
			Vehicle[llave][Llanta]=llanta;
			Business[key][Products]-=1;
			format(string, sizeof(string), "Storage: There are %d products left.", Business[key][Products]);
			SendClientMessage(playerid, COLOR_YELLOW, string);
			GivePlayerMoney(playerid, -50);
			Business[key][Money]+=50;
   		}
     	else
      	{
	  		TogglePlayerControllable(playerid, 1);
     	}
	}
	else if(dialogid == 27)
	{
		if(response)
 		{
		  	if(listitem == 0) // motorbike uniform
		  	{
		  	    SetPlayerSkin(playerid, 284);
       		}
         	else if(listitem == 1) // riot police
          	{
          	    PlayerInfo[playerid][Back] = 4;
          	    PlayerInfo[playerid][BackAmount] = 5;
          	    PlayerInfo[playerid][One] = 21;
				PlayerInfo[playerid][OneAmount] = 5;
				PlayerInfo[playerid][Two] = 21;
				PlayerInfo[playerid][TwoAmount] = 5;
				PlayerInfo[playerid][Three] = 21;
				PlayerInfo[playerid][ThreeAmount] = 5;
				PlayerInfo[playerid][Four] = 10;
				PlayerInfo[playerid][FourAmount] = 500;
				PlayerInfo[playerid][Five] = 17;
				PlayerInfo[playerid][FiveAmount] = 1;
     		}
	      	else if(listitem == 2) // SWAT Assault
	      	{
        		SetPlayerSkin(playerid, 285);
        		PlayerInfo[playerid][Back] = 9;
          	    PlayerInfo[playerid][BackAmount] = 50;
          	    PlayerInfo[playerid][One] = 26;
				PlayerInfo[playerid][OneAmount] = 50;
				PlayerInfo[playerid][Two] = 26;
				PlayerInfo[playerid][TwoAmount] = 50;
				PlayerInfo[playerid][Three] = 26;
				PlayerInfo[playerid][ThreeAmount] = 50;
				PlayerInfo[playerid][Four] = 26;
				PlayerInfo[playerid][FourAmount] = 50;
				PlayerInfo[playerid][Five] = 26;
				PlayerInfo[playerid][FiveAmount] = 50;
	      	}
	      	else if(listitem == 3) // SWAT Sniper
        	{
        	    SetPlayerSkin(playerid, 285);
        	    PlayerInfo[playerid][Back] = 5;
          	    PlayerInfo[playerid][BackAmount] = 5;
          	    PlayerInfo[playerid][One] = 7;
				PlayerInfo[playerid][OneAmount] = 30;
				PlayerInfo[playerid][Two] = 22;
				PlayerInfo[playerid][TwoAmount] = 5;
				PlayerInfo[playerid][Three] = 22;
				PlayerInfo[playerid][ThreeAmount] = 5;
				PlayerInfo[playerid][Four] = 22;
				PlayerInfo[playerid][FourAmount] = 5;
				PlayerInfo[playerid][Five] = 22;
				PlayerInfo[playerid][FiveAmount] = 5;
	      	}
	      	ResetObject(playerid);
   		}
	}
	else if(dialogid == 28)
	{
		if(response)
 		{
		  	if(listitem == 0) // seed
		  	{
		  	    GivePlayerMoney(playerid,-50);
		  	    PlayerInfo[playerid][Hand] = 47;
          	    PlayerInfo[playerid][HandAmount] = 1;
       		}
         	else if(listitem == 1) // bundle of marijuana
          	{
          	    GivePlayerMoney(playerid,-100);
          	    PlayerInfo[playerid][Hand] = 45;
          	    PlayerInfo[playerid][HandAmount] = 20;
     		}
	      	else if(listitem == 2) // bundle of cocaine
	      	{
	      	    GivePlayerMoney(playerid,-200);
        		PlayerInfo[playerid][Hand] = 46;
          	    PlayerInfo[playerid][HandAmount] = 20;
	      	}
	      	else if(listitem == 3) // box of 9mm
        	{
        	    GivePlayerMoney(playerid,-500);
        	    PlayerInfo[playerid][Hand] = 40;
          	    PlayerInfo[playerid][HandAmount] = 5;
	      	}
	      	else if(listitem == 4) // box of uzi
        	{
                GivePlayerMoney(playerid,-750);
                PlayerInfo[playerid][Hand] = 41;
          	    PlayerInfo[playerid][HandAmount] = 5;
	      	}
	      	else if(listitem == 5) // ak-47
        	{
                GivePlayerMoney(playerid,-900);
                PlayerInfo[playerid][Hand] = 8;
          	    PlayerInfo[playerid][HandAmount] = 30;
	      	}
	      	else if(listitem == 6) // box of 9mm clips
        	{
                GivePlayerMoney(playerid,-250);
                PlayerInfo[playerid][Hand] = 42;
          	    PlayerInfo[playerid][HandAmount] = 5;
	      	}
	      	else if(listitem == 7) // box of uzi clips
        	{
                GivePlayerMoney(playerid,-500);
                PlayerInfo[playerid][Hand] = 43;
          	    PlayerInfo[playerid][HandAmount] = 5;
	      	}
	      	else if(listitem == 8) // box of ak-47 clips
        	{
                GivePlayerMoney(playerid,-1000);
                PlayerInfo[playerid][Hand] = 44;
          	    PlayerInfo[playerid][HandAmount] = 5;
	      	}
	      	ResetObject(playerid);
	      	format(string, sizeof(string), "[Smuggler] Here you have your %s. Be careful, fishermen or somebody else could discover us and call police.", Obje[PlayerInfo[playerid][Hand]]);
     		SendClientMessage(playerid, COLOR_YELLOW, string);
   		}
	}
	else if(dialogid == 31)
	{
 		PlayerInfo[playerid][LottoNumber] = strval( inputtext ) ;
	  	if(PlayerInfo[playerid][LottoNumber] > 50 || PlayerInfo[playerid][LottoNumber] < 1)
	  	{
    		SendClientMessage(playerid, COLOR_LIGHTRED, "[Shop assistant] That number isn't within the correct range, so your number will be 50.");
			PlayerInfo[playerid][LottoNumber] = 50;
	  	}
	  	else
	  	{
    		SendClientMessage(playerid, COLOR_WHITE, "[Shop assistant] Good luck in the next lottery, don't lose the ticket (( /stats )).");
	  	}
    }
    else if(dialogid == 32)
  	{
  	    new idgm=0;
      	for (new i = 0; i < 20; i++)
		{
		    if(Carros[i]==PlayerInfo[playerid][VehicleKey2])
			{
			    idgm = i+51;
			}
		}
 		new engine,lights,alarm,doors,bonnet,boot,objective;
  		GetVehicleParamsEx(idgm,engine,lights,alarm,doors,bonnet,boot,objective);
   		SetVehicleParamsEx(idgm,engine,lights,alarm,doors,bonnet,0,objective);
   		if(response)
	  	{
			new idfichero = PlayerInfo[playerid][VehicleKey2]-51;
		  	if(listitem == 0)
		  	{
		  	    if(PlayerInfo[playerid][Hand] !=0)
		  	    {
		  	        SendClientMessage(playerid, COLOR_LIGHTRED, "You have your hands busy.");
		  	        return 1;
		  	    }
		  	    if(Vehicle[idfichero][Maletero]!=0)
		  	    {
      				format(string, sizeof(string), "* %s takes something from the boot and closes it.", NombreEx(playerid));
        			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		  	    }
		  	    PlayerInfo[playerid][Hand]=Vehicle[idfichero][Maletero];
		  	    PlayerInfo[playerid][HandAmount]=Vehicle[idfichero][MaleteroCantidad];
		  	    ResetObject(playerid);
				Vehicle[idfichero][Maletero]=0;
				Vehicle[idfichero][MaleteroCantidad]=0;
       		}
       		if(listitem == 1) { }
         	if(listitem == 2)
          	{
          	    if(Vehicle[idfichero][Maletero]!=0 || PlayerInfo[playerid][Hand]==0) { return 1; }
          	 	new gunAmmo = GetPlayerAmmo(playerid);
	            Vehicle[idfichero][Maletero] = PlayerInfo[playerid][Hand];
	 			if(0 < PlayerInfo[playerid][Hand] < 14)
	 			{
    				Vehicle[idfichero][MaleteroCantidad] = gunAmmo;
 				}
	 			else
	 			{
    				Vehicle[idfichero][MaleteroCantidad] = PlayerInfo[playerid][HandAmount];
    			}
   				format(string, sizeof(string), "* %s puts something in the boot and closes it.", NombreEx(playerid));
    			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
          	    PlayerInfo[playerid][Hand] = 0;
   				PlayerInfo[playerid][HandAmount] = 0;
   				RemovePlayerAttachedObject(playerid, 0);
   				CarryingBox[playerid] = 0;
   				LoopingAnim(playerid, "CARRY", "putdwn105",4.1,0,0,0,0,0);
   				ResetPlayerWeapons(playerid);
     		}
	      	if(listitem == 3)
	      	{
	      	    switch(Vehicle[idfichero][Maletero])
	      	    {
					case 40: {
                        PlayerInfo[playerid][Hand] = 1;
				    	PlayerInfo[playerid][HandAmount] = 17;
					}
					case 41: {
					    PlayerInfo[playerid][Hand] = 6;
				    	PlayerInfo[playerid][HandAmount] = 50;
					}
					case 42: {
					    PlayerInfo[playerid][Hand] = 18;
				    	PlayerInfo[playerid][HandAmount] = 17;
					}
					case 43: {
                        PlayerInfo[playerid][Hand] = 23;
				    	PlayerInfo[playerid][HandAmount] = 50;
					}
					case 44: {
					    PlayerInfo[playerid][Hand] = 25;
				    	PlayerInfo[playerid][HandAmount] = 30;
					}
					case 45: {
					    PlayerInfo[playerid][Hand] = 48;
				    	PlayerInfo[playerid][HandAmount] = 5;
					}
					case 46: {
					    PlayerInfo[playerid][Hand] = 49;
				    	PlayerInfo[playerid][HandAmount] = 1;
					}
					default: return 1;
				}
    			Vehicle[idfichero][MaleteroCantidad] -= 1;
				if(Vehicle[idfichero][MaleteroCantidad]<1)
				{
					Vehicle[idfichero][Maletero]=0;
				}
				ResetObject(playerid);
	      	}
   		}
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

//-----[Other functions]-----
public SaveAccount(playerid, password[])
{
    new string3[64];
    new playername3[MAX_PLAYER_NAME];
    GetPlayerName(playerid, playername3, sizeof(playername3));
    format(string3, sizeof(string3), "users/%s.ini", playername3);
    new File: hFile = fopen(string3, io_write);
    if (hFile)
    {
         strmid(PlayerInfo[playerid][Password], password, 0, strlen(password), 255);
         new var[64];
         format(var, 64, "Password=%s\n", PlayerInfo[playerid][Password]);fwrite(hFile, var);
         format(var, 64, "Admin=%d\n",PlayerInfo[playerid][Admin]);fwrite(hFile, var);
         format(var, 64, "RolePoints=%d\n",PlayerInfo[playerid][RolePoints]);fwrite(hFile, var);
         format(var, 64, "Bank=%d\n",PlayerInfo[playerid][Bank]);fwrite(hFile, var);
         PlayerInfo[playerid][Money] = GetPlayerMoney(playerid);
         format(var, 64, "Money=%d\n",PlayerInfo[playerid][Money]);fwrite(hFile, var);
         format(var, 64, "Level=%d\n",PlayerInfo[playerid][Level]);fwrite(hFile, var);
         format(var, 64, "Hours=%d\n",PlayerInfo[playerid][Hours]);fwrite(hFile, var);
         format(var, 64, "Sex=%d\n",PlayerInfo[playerid][Sex]);fwrite(hFile, var);
         format(var, 64, "Age=%d\n",PlayerInfo[playerid][Age]);fwrite(hFile, var);
         format(var, 64, "PhoneNumber=%d\n",PlayerInfo[playerid][PhoneNumber]);fwrite(hFile, var);
         new Float:x, Float:y, Float:z;
         GetPlayerPos(playerid,x,y,z);
         PlayerInfo[playerid][Pos_x] = x;
         PlayerInfo[playerid][Pos_y] = y;
         PlayerInfo[playerid][Pos_z] = z;
         PlayerInfo[playerid][Interior] = GetPlayerInterior(playerid);
         PlayerInfo[playerid][VirtualWorld] = GetPlayerVirtualWorld(playerid);
         format(var, 64, "Pos_x=%.1f\n",PlayerInfo[playerid][Pos_x]);fwrite(hFile, var);
         format(var, 64, "Pos_y=%.1f\n",PlayerInfo[playerid][Pos_y]);fwrite(hFile, var);
         format(var, 64, "Pos_z=%.1f\n",PlayerInfo[playerid][Pos_z]);fwrite(hFile, var);
         format(var, 64, "Interior=%d\n",PlayerInfo[playerid][Interior]);fwrite(hFile, var);
         format(var, 64, "VirtualWorld=%d\n",PlayerInfo[playerid][VirtualWorld]);fwrite(hFile, var);
         format(var, 64, "Skin=%d\n",PlayerInfo[playerid][Skin]);fwrite(hFile, var);
         format(var, 64, "Job=%d\n",PlayerInfo[playerid][Job]);fwrite(hFile, var);
         format(var, 64, "Faction=%d\n",PlayerInfo[playerid][Faction]);fwrite(hFile, var);
         format(var, 64, "Rank=%d\n",PlayerInfo[playerid][Rank]);fwrite(hFile, var);
         format(var, 64, "HouseKey=%d\n",PlayerInfo[playerid][HouseKey]);fwrite(hFile, var);
         format(var, 64, "BusinessKey=%d\n",PlayerInfo[playerid][BusinessKey]);fwrite(hFile, var);
         format(var, 64, "VehicleKey=%d\n",PlayerInfo[playerid][VehicleKey]);fwrite(hFile, var);
         format(var, 64, "VehicleKey2=%d\n",PlayerInfo[playerid][VehicleKey2]);fwrite(hFile, var);
         format(var, 64, "LottoNumber=%d\n",PlayerInfo[playerid][LottoNumber]);fwrite(hFile, var);
         format(var, 64, "CriminalSkill=%d\n",PlayerInfo[playerid][CriminalSkill]);fwrite(hFile, var);
         format(var, 64, "Prison=%d\n",PlayerInfo[playerid][Prison]);fwrite(hFile, var);
         format(var, 64, "Licence=%d\n",PlayerInfo[playerid][Licence]);fwrite(hFile, var);
         format(var, 64, "Dead=%d\n",PlayerInfo[playerid][Dead]);fwrite(hFile, var);
         format(var, 64, "One=%d\n",PlayerInfo[playerid][One]);fwrite(hFile, var);
         format(var, 64, "OneAmount=%d\n",PlayerInfo[playerid][OneAmount]);fwrite(hFile, var);
         format(var, 64, "Two=%d\n",PlayerInfo[playerid][Two]);fwrite(hFile, var);
         format(var, 64, "TwoAmount=%d\n",PlayerInfo[playerid][TwoAmount]);fwrite(hFile, var);
         format(var, 64, "Three=%d\n",PlayerInfo[playerid][Three]);fwrite(hFile, var);
         format(var, 64, "ThreeAmount=%d\n",PlayerInfo[playerid][ThreeAmount]);fwrite(hFile, var);
         format(var, 64, "Four=%d\n",PlayerInfo[playerid][Four]);fwrite(hFile, var);
         format(var, 64, "FourAmount=%d\n",PlayerInfo[playerid][FourAmount]);fwrite(hFile, var);
         format(var, 64, "Five=%d\n",PlayerInfo[playerid][Five]);fwrite(hFile, var);
         format(var, 64, "FiveAmount=%d\n",PlayerInfo[playerid][FiveAmount]);fwrite(hFile, var);
         format(var, 64, "Hand=%d\n",PlayerInfo[playerid][Hand]);fwrite(hFile, var);
         format(var, 64, "HandAmount=%d\n",PlayerInfo[playerid][HandAmount]);fwrite(hFile, var);
         format(var, 64, "Back=%d\n",PlayerInfo[playerid][Back]);fwrite(hFile, var);
         format(var, 64, "BackAmount=%d\n",PlayerInfo[playerid][BackAmount]);fwrite(hFile, var);
         fclose(hFile);
    }
    return 1;
}

public LoginAccount(playerid,password[])
{
    new string2[64];
	new playername2[MAX_PLAYER_NAME];
    GetPlayerName(playerid, playername2, sizeof(playername2));
	format(string2, sizeof(string2), "users/%s.ini", playername2);
	new File: UserFile = fopen(string2, io_read);
	if ( UserFile )
	{
	    new PassData[256];
	    new keytmp[256], valtmp[256];
	    fread( UserFile , PassData , sizeof( PassData ) );
	    keytmp = ini_GetKey( PassData );
	    if( strcmp( keytmp , "Password" , true ) == 0 )
		{
			valtmp = ini_GetValue( PassData );
			strmid(PlayerInfo[playerid][Password], valtmp, 0, strlen(valtmp)-1, 255);
		}
		if(strcmp(PlayerInfo[playerid][Password],password, true ) == 0 )
		{
            new key[ 256 ] , val[ 256 ];
            new Data[ 256 ];
            while ( fread( UserFile , Data , sizeof( Data ) ) )
		    {
		        key = ini_GetKey( Data );
		        if( strcmp( key , "Admin" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][Admin] = strval( val ); }
		        if( strcmp( key , "RolePoints" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][RolePoints] = strval( val ); }
	    	    if( strcmp( key , "Bank" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][Bank] = strval( val ); }
	    	    if( strcmp( key , "Money" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][Money] = strval( val ); }
    	        if( strcmp( key , "Level" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][Level] = strval( val ); }
	    	    if( strcmp( key , "Hours" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][Hours] = strval( val ); }
	    	    if( strcmp( key , "Sex" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][Sex] = strval( val ); }
	    	    if( strcmp( key , "Age" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][Age] = strval( val ); }
	    	    if( strcmp( key , "PhoneNumber" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][PhoneNumber] = strval( val ); }
	    	    if( strcmp( key , "Pos_x" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][Pos_x] = floatstr( val ); }
                if( strcmp( key , "Pos_y" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][Pos_y] = floatstr( val ); }
	            if( strcmp( key , "Pos_z" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][Pos_z] = floatstr( val ); }
	            if( strcmp( key , "Interior" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][Interior] = strval( val ); }
	            if( strcmp( key , "VirtualWorld" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][VirtualWorld] = strval( val ); }
	            if( strcmp( key , "Skin" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][Skin] = strval( val ); }
	            if( strcmp( key , "Job" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][Job] = strval( val ); }
	            if( strcmp( key , "Faction" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][Faction] = strval( val ); }
	            if( strcmp( key , "Rank" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][Rank] = strval( val ); }
	            if( strcmp( key , "HouseKey" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][HouseKey] = strval( val ); }
	            if( strcmp( key , "BusinessKey" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][BusinessKey] = strval( val ); }
	            if( strcmp( key , "VehicleKey" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][VehicleKey] = strval( val ); }
	            if( strcmp( key , "VehicleKey2" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][VehicleKey2] = strval( val ); }
	            if( strcmp( key , "VehicleKey2" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][VehicleKey2] = strval( val ); }
	            if( strcmp( key , "LottoNumber" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][LottoNumber] = strval( val ); }
	            if( strcmp( key , "CriminalSkill" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][CriminalSkill] = strval( val ); }
	            if( strcmp( key , "Prison" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][Prison] = strval( val ); }
	            if( strcmp( key , "Licence" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][Licence] = strval( val ); }
	            if( strcmp( key , "Dead" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][Dead] = strval( val ); }
	            if( strcmp( key , "One" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][One] = strval( val ); }
	            if( strcmp( key , "OneAmount" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][OneAmount] = strval( val ); }
	            if( strcmp( key , "Two" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][Two] = strval( val ); }
	            if( strcmp( key , "TwoAmount" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][TwoAmount] = strval( val ); }
	            if( strcmp( key , "Three" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][Three] = strval( val ); }
	            if( strcmp( key , "ThreeAmount" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][ThreeAmount] = strval( val ); }
	            if( strcmp( key , "Four" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][Four] = strval( val ); }
	            if( strcmp( key , "FourAmount" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][FourAmount] = strval( val ); }
	            if( strcmp( key , "Five" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][Five] = strval( val ); }
	            if( strcmp( key , "FiveAmount" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][FiveAmount] = strval( val ); }
	            if( strcmp( key , "Hand" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][Hand] = strval( val ); }
	            if( strcmp( key , "HandAmount" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][HandAmount] = strval( val ); }
          		if( strcmp( key , "Back" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][Back] = strval( val ); }
    			if( strcmp( key , "BackAmount" , true ) == 0 ) { val = ini_GetValue( Data ); PlayerInfo[playerid][BackAmount] = strval( val ); }
      		}
	     	fclose(UserFile);
      	}
      	else
	  	{
   			Kick(playerid);
	        return 1;
		}
   		SetPlayerColor(playerid,PLAYER_COLOR);
   		SetPlayerScore(playerid,PlayerInfo[playerid][Level]);
   		GivePlayerMoney(playerid,PlayerInfo[playerid][Money]);
   		SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 50);
   		SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI, 50);
   		SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN, 0);
   		SetPlayerSkillLevel(playerid, WEAPONSKILL_AK47, 0);
   		SetPlayerMapIcon(playerid, 0, 1555.0870,-1675.6030,16.1953, 30, COLOR_YELLOW); // LSPD
   		//-----[Job icons]-----
   		SetPlayerMapIcon(playerid, 1, -382.7005,-1426.2778,26.2496, 56, COLOR_YELLOW); // farmer
   		SetPlayerMapIcon(playerid, 2, 2195.6436,-1973.2948,13.5589, 56, COLOR_YELLOW); // dustman
   		SetPlayerMapIcon(playerid, 3, 2731.6450,-2416.8840,13.6278, 51, COLOR_YELLOW); // lorry driver
   		SetPlayerMapIcon(playerid, 4, 2105.0642,-1806.5902,13.5547, 29, COLOR_YELLOW); // pizza deliverer
   		SetPlayerMapIcon(playerid, 5, 1219.2954,-1812.5404,16.5938, 56, COLOR_YELLOW); // public transporter
   		SetPlayerMapIcon(playerid, 6, 2411.8665,-2547.5198,13.6517, 56, COLOR_YELLOW); // fisher
   		// Others.
   		SetPlayerMapIcon(playerid, 7, 542.3122,-1293.6472,17.2422, 55, COLOR_YELLOW); // Dealership.
   		SetPlayerMapIcon(playerid, 8, 405.8781,-1724.5875,8.6603, 63, COLOR_YELLOW); // Santa Maria Beach Workshop.
        PreloadAnimLib(playerid,"AIRPORT");
        PreloadAnimLib(playerid,"ATTRACTORS");
        PreloadAnimLib(playerid,"BAR");
		PreloadAnimLib(playerid,"BASEBALL");
		PreloadAnimLib(playerid,"BD_FIRE");
		PreloadAnimLib(playerid,"BEACH");
		PreloadAnimLib(playerid,"BENCHPRESS");
		PreloadAnimLib(playerid,"BF_INJECTION");
		PreloadAnimLib(playerid,"BIKED");
		PreloadAnimLib(playerid,"BIKEH");
		PreloadAnimLib(playerid,"BIKELEAP");
		PreloadAnimLib(playerid,"BIKES");
		PreloadAnimLib(playerid,"BIKEV");
		PreloadAnimLib(playerid,"BIKE_DBZ");
		PreloadAnimLib(playerid,"BMX");
		PreloadAnimLib(playerid,"BOMBER");
		PreloadAnimLib(playerid,"BOX");
		PreloadAnimLib(playerid,"BSKTBALL");
		PreloadAnimLib(playerid,"BUDDY");
		PreloadAnimLib(playerid,"BUS");
		PreloadAnimLib(playerid,"CAMERA");
		PreloadAnimLib(playerid,"CAR");
		PreloadAnimLib(playerid,"CARRY");
		PreloadAnimLib(playerid,"CAR_CHAT");
		PreloadAnimLib(playerid,"CASINO");
		PreloadAnimLib(playerid,"CHAINSAW");
		PreloadAnimLib(playerid,"CHOPPA");
		PreloadAnimLib(playerid,"CLOTHES");
		PreloadAnimLib(playerid,"COACH");
		PreloadAnimLib(playerid,"COLT45");
		PreloadAnimLib(playerid,"COP_AMBIENT");
		PreloadAnimLib(playerid,"COP_DVBYZ");
		PreloadAnimLib(playerid,"CRACK");
		PreloadAnimLib(playerid,"CRIB");
		PreloadAnimLib(playerid,"DAM_JUMP");
		PreloadAnimLib(playerid,"DANCING");
		PreloadAnimLib(playerid,"DEALER");
		PreloadAnimLib(playerid,"DILDO");
        PreloadAnimLib(playerid,"DODGE");
		PreloadAnimLib(playerid,"DOZER");
		PreloadAnimLib(playerid,"DRIVEBYS");
		PreloadAnimLib(playerid,"FAT");
		PreloadAnimLib(playerid,"FIGHT_B");
		PreloadAnimLib(playerid,"FIGHT_C");
		PreloadAnimLib(playerid,"FIGHT_D");
		PreloadAnimLib(playerid,"FIGHT_E");
		PreloadAnimLib(playerid,"FINALE");
		PreloadAnimLib(playerid,"FINALE2");
		PreloadAnimLib(playerid,"FLAME");
		PreloadAnimLib(playerid,"FLOWERS");
		PreloadAnimLib(playerid,"FOOD");
		PreloadAnimLib(playerid,"FREEWEIGHTS");
		PreloadAnimLib(playerid,"GANGS");
		PreloadAnimLib(playerid,"GHANDS");
		PreloadAnimLib(playerid,"GHETTO_DB");
		PreloadAnimLib(playerid,"GOGGLES");
		PreloadAnimLib(playerid,"GRAFFITI");
		PreloadAnimLib(playerid,"GRAVEYARD");
		PreloadAnimLib(playerid,"GRENADE");
		PreloadAnimLib(playerid,"GYMNASIUM");
		PreloadAnimLib(playerid,"HAIRCUTS");
		PreloadAnimLib(playerid,"HEIST9");
		PreloadAnimLib(playerid,"INT_HOUSE");
		PreloadAnimLib(playerid,"INT_OFFICE");
		PreloadAnimLib(playerid,"INT_SHOP");
		PreloadAnimLib(playerid,"JST_BUISNESS");
		PreloadAnimLib(playerid,"KART");
		PreloadAnimLib(playerid,"KISSING");
		PreloadAnimLib(playerid,"KNIFE");
		PreloadAnimLib(playerid,"LAPDAN1");
		PreloadAnimLib(playerid,"LAPDAN2");
		PreloadAnimLib(playerid,"LAPDAN3");
		PreloadAnimLib(playerid,"LOWRIDER");
		PreloadAnimLib(playerid,"MD_CHASE");
		PreloadAnimLib(playerid,"MD_END");
		PreloadAnimLib(playerid,"MEDIC");
		PreloadAnimLib(playerid,"MISC");
		PreloadAnimLib(playerid,"MTB");
		PreloadAnimLib(playerid,"MUSCULAR");
		PreloadAnimLib(playerid,"NEVADA");
		PreloadAnimLib(playerid,"ON_LOOKERS");
		PreloadAnimLib(playerid,"OTB");
		PreloadAnimLib(playerid,"PARACHUTE");
		PreloadAnimLib(playerid,"PARK");
		PreloadAnimLib(playerid,"PAULNMAC");
		PreloadAnimLib(playerid,"PED");
		PreloadAnimLib(playerid,"PLAYER_DVBYS");
		PreloadAnimLib(playerid,"PLAYIDLES");
		PreloadAnimLib(playerid,"POLICE");
		PreloadAnimLib(playerid,"POOL");
		PreloadAnimLib(playerid,"POOR");
		PreloadAnimLib(playerid,"PYTHON");
		PreloadAnimLib(playerid,"QUAD");
		PreloadAnimLib(playerid,"QUAD_DBZ");
		PreloadAnimLib(playerid,"RAPPING");
		PreloadAnimLib(playerid,"RIFLE");
		PreloadAnimLib(playerid,"RIOT");
		PreloadAnimLib(playerid,"ROB_BANK");
		PreloadAnimLib(playerid,"ROCKET");
		PreloadAnimLib(playerid,"RUSTLER");
		PreloadAnimLib(playerid,"RYDER");
		PreloadAnimLib(playerid,"SCRATCHING");
		PreloadAnimLib(playerid,"SHAMAL");
		PreloadAnimLib(playerid,"SHOP");
		PreloadAnimLib(playerid,"SHOTGUN");
		PreloadAnimLib(playerid,"SILENCED");
		PreloadAnimLib(playerid,"SKATE");
		PreloadAnimLib(playerid,"SMOKING");
		PreloadAnimLib(playerid,"SNIPER");
		PreloadAnimLib(playerid,"SPRAYCAN");
		PreloadAnimLib(playerid,"STRIP");
		PreloadAnimLib(playerid,"SUNBATHE");
		PreloadAnimLib(playerid,"SWAT");
		PreloadAnimLib(playerid,"SWEET");
		PreloadAnimLib(playerid,"SWIM");
		PreloadAnimLib(playerid,"SWORD");
		PreloadAnimLib(playerid,"TANK");
		PreloadAnimLib(playerid,"TATTOOS");
		PreloadAnimLib(playerid,"TEC");
		PreloadAnimLib(playerid,"TRAIN");
		PreloadAnimLib(playerid,"TRUCK");
		PreloadAnimLib(playerid,"UZI");
		PreloadAnimLib(playerid,"VAN");
		PreloadAnimLib(playerid,"VENDING");
		PreloadAnimLib(playerid,"VORTEX");
		PreloadAnimLib(playerid,"WAYFARER");
		PreloadAnimLib(playerid,"WEAPONS");
		PreloadAnimLib(playerid,"WUZI");
		PreloadAnimLib(playerid,"WOP");
		PreloadAnimLib(playerid,"GFUNK");
		PreloadAnimLib(playerid,"RUNNINGMAN");
	   	// Traffic lights removal, center in Pershing Square (by Ivanobishev).
	   	RemoveBuildingForPlayer(playerid, 1262, 1529.8416,-1593.3516,13.3906, 1500.0);
	   	RemoveBuildingForPlayer(playerid, 1283, 1529.8416,-1593.3516,13.3906, 1500.0);
	   	RemoveBuildingForPlayer(playerid, 1315, 1529.8416,-1593.3516,13.3906, 1500.0);
	   	RemoveBuildingForPlayer(playerid, 1350, 1529.8416,-1593.3516,13.3906, 1500.0);
	   	RemoveBuildingForPlayer(playerid, 1351, 1529.8416,-1593.3516,13.3906, 1500.0);
	   	RemoveBuildingForPlayer(playerid, 3516, 1529.8416,-1593.3516,13.3906, 1500.0);
		SetPlayerHealth(playerid, 100);
		SetPlayerPos(playerid, PlayerInfo[playerid][Pos_x], PlayerInfo[playerid][Pos_y], PlayerInfo[playerid][Pos_z]);
		SetPlayerSkin(playerid, PlayerInfo[playerid][Skin]);
	}
 	return 1;
}

stock ini_GetValue( line[] )
{
	new valRes[256];
	valRes[0]=0;
	if ( strfind( line , "=" , true ) == -1 ) return valRes;
	strmid( valRes , line , strfind( line , "=" , true )+1 , strlen( line ) , sizeof( valRes ) );
	return valRes;
}

stock ini_GetKey( line[] )
{
	new keyRes[256];
	keyRes[0] = 0;
    if ( strfind( line , "=" , true ) == -1 ) return keyRes;
    strmid( keyRes , line , 0 , strfind( line , "=" , true ) , sizeof( keyRes) );
    return keyRes;
}

public ClearChatbox(playerid, lines)
{
	if (IsPlayerConnected(playerid))
	{
		for(new i=0; i<lines; i++)
		{
			SendClientMessage(playerid, COLOR_WHITE, " ");
		}
	}
	return 1;
}

public ShowStats(playerid,targetid)
{
    if(IsPlayerConnected(playerid)&&IsPlayerConnected(targetid))
	{
		new cash =  GetPlayerMoney(targetid);
		new faction[25];
		if(PlayerInfo[targetid][Faction] == 0) { faction = "-"; }
		else if(PlayerInfo[targetid][Faction] == 1) { faction = "LSPD"; }
		else if(PlayerInfo[targetid][Faction] == 2) { faction = "LSMD"; }
		else if(PlayerInfo[targetid][Faction] == 3) { faction = "SAN"; }
		// Non-governmental factions.
		else if(PlayerInfo[targetid][Faction] >= 4) { faction = "Mafia"; }
		new rank[30];
		if(PlayerInfo[targetid][Rank] == 0) { rank = "-"; }
		if(PlayerInfo[targetid][Faction] == 1)
		{
		    if(PlayerInfo[targetid][Rank] == 1) { rank = "Cadet"; }
			else if(PlayerInfo[targetid][Rank] == 2) { rank = "Official"; }
			else if(PlayerInfo[targetid][Rank] == 3) { rank = "Detective"; }
			else if(PlayerInfo[targetid][Rank] == 4) { rank = "Major"; }
			else if(PlayerInfo[targetid][Rank] == 5) { rank = "Superintendent"; }
		}
		if(PlayerInfo[targetid][Faction] == 2)
		{
		    if(PlayerInfo[targetid][Rank] == 1) { rank = "Paramedic"; }
			else if(PlayerInfo[targetid][Rank] == 2) { rank = "Fireman"; }
			else if(PlayerInfo[targetid][Rank] == 3) { rank = "Firemen coordinator"; }
			else if(PlayerInfo[targetid][Rank] == 4) { rank = "Doctor"; }
			else if(PlayerInfo[targetid][Rank] == 5) { rank = "Hospital director"; }
		}
		if(PlayerInfo[targetid][Faction] == 3)
		{
		    if(PlayerInfo[targetid][Rank] == 1) { rank = "Apprentice"; }
			else if(PlayerInfo[targetid][Rank] == 2) { rank = "Journalist"; }
			else if(PlayerInfo[targetid][Rank] == 3) { rank = "Director"; }
		}
		if(PlayerInfo[targetid][Faction] >= 4)
		{
		    if(PlayerInfo[targetid][Rank] == 1) { rank = "Rookie"; }
			else if(PlayerInfo[targetid][Rank] == 2) { rank = "Gangster"; }
			else if(PlayerInfo[targetid][Rank] == 3) { rank = "Leader"; }
		}
		new job[30];
		if(PlayerInfo[targetid][Job] == 0) { job = "-"; }
		else if(PlayerInfo[targetid][Job] == 1) { job = "Farmer"; }
		else if(PlayerInfo[targetid][Job] == 2) { job = "Dustman"; }
        else if(PlayerInfo[targetid][Job] == 3) { job = "Lorry driver"; }
        else if(PlayerInfo[targetid][Job] == 4) { job = "Pizza deliverer"; }
        else if(PlayerInfo[targetid][Job] == 5) { job = "Public transporter"; }
        else if(PlayerInfo[targetid][Job] == 6) { job = "Fisher"; }
        else if(PlayerInfo[targetid][Job] == 7) { job = "Mechanic"; }
        else if(PlayerInfo[targetid][Job] == 8) { job = "Criminal"; }
		new name[MAX_PLAYER_NAME];
		GetPlayerName(targetid, name, sizeof(name));
		new coordsstring[256];
		format(coordsstring, sizeof(coordsstring),"_________________________| Information |_________________________");
		SendClientMessage(playerid, COLOR_GREEN,coordsstring);
		format(coordsstring, sizeof(coordsstring), "Name: [%s]  Age: [%d]  Cash: [$%d]  Bank: [$%d]", name,PlayerInfo[targetid][Age],cash,PlayerInfo[targetid][Bank]);
		SendClientMessage(playerid, COLOR_LIGHTYELLOW,coordsstring);
		format(coordsstring, sizeof(coordsstring), "Phone number: [%d]", PlayerInfo[playerid][PhoneNumber]);
		SendClientMessage(playerid, COLOR_LIGHTYELLOW,coordsstring);
		format(coordsstring, sizeof(coordsstring),"_________________________| Professional data |________________________");
		SendClientMessage(playerid, COLOR_GREEN,coordsstring);
		format(coordsstring, sizeof(coordsstring), "Job: [%s]  Faction: [%s]  Rank: [%s]", job, faction, rank);
		SendClientMessage(playerid, COLOR_LIGHTYELLOW,coordsstring);
        format(coordsstring, sizeof(coordsstring),"_________________________| Properties |__________________________");
        SendClientMessage(playerid, COLOR_GREEN,coordsstring);
		format(coordsstring, sizeof(coordsstring), "House: [%d]  Business: [%d]  Vehicles: [%d - %d]  Lotto number: [%d]", PlayerInfo[targetid][HouseKey],PlayerInfo[targetid][BusinessKey],PlayerInfo[targetid][VehicleKey],PlayerInfo[targetid][VehicleKey2],PlayerInfo[playerid][LottoNumber]);
		SendClientMessage(playerid, COLOR_LIGHTYELLOW,coordsstring);
		format(coordsstring, sizeof(coordsstring),"_________________________| OOC |________________________________");
		SendClientMessage(playerid, COLOR_GREEN,coordsstring);
	    format(coordsstring, sizeof(coordsstring), "Level: [%d]  Paydays received: [%d/%d]  Role points: [%d]",PlayerInfo[targetid][Level],PlayerInfo[targetid][Hours],PlayerInfo[targetid][Level]*10,PlayerInfo[targetid][RolePoints]);
		SendClientMessage(playerid, COLOR_LIGHTYELLOW,coordsstring);
	}
}

public LoadHouses()
{
	new arrCoords[23][64];
	new strFromFile2[256];
	new File: file = fopen("houses/houses.cfg", io_read);
	if (file)
	{
		new idx;
		while (idx < sizeof(House))
		{
			fread(file, strFromFile2);
			split(strFromFile2, arrCoords, ',');
			House[idx][Entrancex] = floatstr(arrCoords[0]);
			House[idx][Entrancey] = floatstr(arrCoords[1]);
			House[idx][Entrancez] = floatstr(arrCoords[2]);
			House[idx][Exitx] = floatstr(arrCoords[3]);
			House[idx][Exity] = floatstr(arrCoords[4]);
			House[idx][Exitz] = floatstr(arrCoords[5]);
			House[idx][Interior] = strval(arrCoords[6]);
			strmid(House[idx][Owner], arrCoords[7], 0, strlen(arrCoords[7]), 255);
			strmid(House[idx][Description], arrCoords[8], 0, strlen(arrCoords[8]), 255);
			House[idx][Owned] = strval(arrCoords[9]);
			House[idx][Price] = strval(arrCoords[10]);
			House[idx][Time] = strval(arrCoords[11]);
			House[idx][Locked] = strval(arrCoords[12]);
			House[idx][Seed] = strval(arrCoords[13]);
			House[idx][Seedx] = floatstr(arrCoords[14]);
			House[idx][Seedy] = floatstr(arrCoords[15]);
			House[idx][Seedz] = floatstr(arrCoords[16]);
			House[idx][Closet1] = strval(arrCoords[17]);
			House[idx][Amount1] = strval(arrCoords[18]);
			House[idx][Closet2] = strval(arrCoords[19]);
			House[idx][Amount2] = strval(arrCoords[20]);
			House[idx][Closet3] = strval(arrCoords[21]);
			House[idx][Amount3] = strval(arrCoords[22]);
			idx++;
		}
		fclose(file);
	}
	return 1;
}

public LoadBusinesses()
{
	new arrCoords[15][64];
	new strFromFile2[256];
	new File: file = fopen("businesses/businesses.cfg", io_read);
	if (file)
	{
		new idx;
		while (idx < sizeof(Business))
		{
			fread(file, strFromFile2);
			split(strFromFile2, arrCoords, ',');
			Business[idx][Entrancex] = floatstr(arrCoords[0]);
			Business[idx][Entrancey] = floatstr(arrCoords[1]);
			Business[idx][Entrancez] = floatstr(arrCoords[2]);
			Business[idx][Exitx] = floatstr(arrCoords[3]);
			Business[idx][Exity] = floatstr(arrCoords[4]);
			Business[idx][Exitz] = floatstr(arrCoords[5]);
			Business[idx][Interior] = strval(arrCoords[6]);
			strmid(Business[idx][Owner], arrCoords[7], 0, strlen(arrCoords[7]), 255);
			strmid(Business[idx][Description], arrCoords[8], 0, strlen(arrCoords[8]), 255);
			Business[idx][Owned] = strval(arrCoords[9]);
			Business[idx][Price] = strval(arrCoords[10]);
			Business[idx][Time] = strval(arrCoords[11]);
			Business[idx][Type] = strval(arrCoords[12]);
			Business[idx][Products] = strval(arrCoords[13]);
			Business[idx][Money] = strval(arrCoords[14]);
			idx++;
		}
		fclose(file);
	}
	return 1;
}

public LoadVehicles()
{
	new arrCoords[17][64];
	new strFromFile2[256];
	new File: file = fopen("vehicles/vehicles.cfg", io_read);
	if (file)
	{
		new idx;
		while (idx < sizeof(Vehicle))
		{
			fread(file, strFromFile2);
			split(strFromFile2, arrCoords, ',');
			Vehicle[idx][Modelo] = strval(arrCoords[0]);
			strmid(Vehicle[idx][Matricula], arrCoords[1], 0, strlen(arrCoords[1]), 255);
			Vehicle[idx][Posicionx] = floatstr(arrCoords[2]);
			Vehicle[idx][Posiciony] = floatstr(arrCoords[3]);
			Vehicle[idx][Posicionz] = floatstr(arrCoords[4]);
			Vehicle[idx][Angulo] = floatstr(arrCoords[5]);
			Vehicle[idx][Interior] = strval(arrCoords[6]);
			Vehicle[idx][Virtual] = strval(arrCoords[7]);
			strmid(Vehicle[idx][Dueno], arrCoords[8], 0, strlen(arrCoords[8]), 255);
			Vehicle[idx][Comprado] = strval(arrCoords[9]);
			Vehicle[idx][Tiempo] = strval(arrCoords[10]);
			Vehicle[idx][Cerradura] = strval(arrCoords[11]);
			Vehicle[idx][ColorUno] = strval(arrCoords[12]);
			Vehicle[idx][ColorDos] = strval(arrCoords[13]);
			Vehicle[idx][Maletero] = strval(arrCoords[14]);
			Vehicle[idx][MaleteroCantidad] = strval(arrCoords[15]);
			Vehicle[idx][Llanta] = strval(arrCoords[16]);
			idx++;
		}
		fclose(file);
	}
	return 1;
}

public SaveThings()
{
    new idx;
    new File: file2;
    while (idx < sizeof(House))
    {
        new coordsstring[256];
        format(coordsstring, sizeof(coordsstring), "%f,%f,%f,%f,%f,%f,%d,%s,%s,%d,%d,%d,%d,%d,%f,%f,%f,%d,%d,%d,%d,%d,%d\n",
        House[idx][Entrancex],
        House[idx][Entrancey],
        House[idx][Entrancez],
        House[idx][Exitx],
        House[idx][Exity],
        House[idx][Exitz],
        House[idx][Interior],
        House[idx][Owner],
        House[idx][Description],
        House[idx][Owned],
		House[idx][Price],
		House[idx][Time],
		House[idx][Locked],
		House[idx][Seed],
		House[idx][Seedx],
		House[idx][Seedy],
		House[idx][Seedz],
		House[idx][Closet1],
		House[idx][Amount1],
		House[idx][Closet2],
		House[idx][Amount2],
		House[idx][Closet3],
        House[idx][Amount3]);

        if(idx == 0)
        {
            file2 = fopen("houses/houses.cfg", io_write);
        }
        else
        {
            file2 = fopen("houses/houses.cfg", io_append);
        }
        fwrite(file2, coordsstring);
        idx++;
        fclose(file2);
    }
    idx = 0;
    while (idx < sizeof(Business))
    {
        new coordsstring[256];
        format(coordsstring, sizeof(coordsstring), "%f,%f,%f,%f,%f,%f,%d,%s,%s,%d,%d,%d,%d,%d,%d\n",
        Business[idx][Entrancex],
        Business[idx][Entrancey],
        Business[idx][Entrancez],
        Business[idx][Exitx],
        Business[idx][Exity],
        Business[idx][Exitz],
        Business[idx][Interior],
        Business[idx][Owner],
        Business[idx][Description],
        Business[idx][Owned],
		Business[idx][Price],
		Business[idx][Time],
		Business[idx][Type],
		Business[idx][Products],
        Business[idx][Money]);
        if(idx == 0)
        {
            file2 = fopen("businesses/businesses.cfg", io_write);
        }
        else
        {
            file2 = fopen("businesses/businesses.cfg", io_append);
        }
        fwrite(file2, coordsstring);
        idx++;
        fclose(file2);
    }
    idx = 0;
    while (idx < sizeof(Vehicle))
    {
        new coordsstring[256];
        format(coordsstring, sizeof(coordsstring), "%d,%s,%f,%f,%f,%f,%d,%d,%s,%d,%d,%d,%d,%d,%d,%d,%d\n",
		Vehicle[idx][Modelo],
        Vehicle[idx][Matricula],
        Vehicle[idx][Posicionx],
        Vehicle[idx][Posiciony],
        Vehicle[idx][Posicionz],
        Vehicle[idx][Angulo],
        Vehicle[idx][Interior],
        Vehicle[idx][Virtual],
        Vehicle[idx][Dueno],
        Vehicle[idx][Comprado],
        Vehicle[idx][Tiempo],
        Vehicle[idx][Cerradura],
        Vehicle[idx][ColorUno],
        Vehicle[idx][ColorDos],
        Vehicle[idx][Maletero],
        Vehicle[idx][MaleteroCantidad],
        Vehicle[idx][Llanta]);
        if(idx == 0)
        {
            file2 = fopen("vehicles/vehicles.cfg", io_write);
        }
        else
        {
            file2 = fopen("vehicles/vehicles.cfg", io_append);
        }
        fwrite(file2, coordsstring);
        idx++;
        fclose(file2);
    }
    return 1;
}

public split(const strsrc[], strdest[][], delimiter)
{
	new i, li;
	new aNum;
	new len;
	while(i <= strlen(strsrc)){
	    if(strsrc[i]==delimiter || i==strlen(strsrc)){
	        len = strmid(strdest[aNum], strsrc, li, i, 128);
	        strdest[aNum][len] = 0;
	        li = i+1;
	        aNum++;
		}
		i++;
	}
	return 1;
}

public PayDay()
{
	delito = 0;
    Clima = random(2);
    switch(Clima)
   	{
    	case 0: { SetWeather(10); DefaultWeather=10; }
     	case 1: { SetWeather(20); DefaultWeather=20; }
    }
	new string[128];
	new account;
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
		    if(PlayerInfo[i][Level] > 0)
		    {
				new playername2[MAX_PLAYER_NAME];
				GetPlayerName(i, playername2, sizeof(playername2));
				account = PlayerInfo[i][Bank];
				new Empleo[MAX_PLAYERS];
				if(PlayerInfo[i][Faction] == 1 )
				{
    				if(PlayerInfo[i][Rank] == 1) { Empleo[i] = 150; } // Cadet
        			else if(PlayerInfo[i][Rank] == 2) { Empleo[i] = 400; } // Official
           			else if(PlayerInfo[i][Rank] == 3) { Empleo[i] = 600; } // Detective
              		else if(PlayerInfo[i][Rank] == 4) { Empleo[i] = 700; } // Major
                	else if(PlayerInfo[i][Rank] == 5) { Empleo[i] = 900; } // Superintendent
               	}
               	if(PlayerInfo[i][Faction] == 2 )
				{
    				if(PlayerInfo[i][Rank] == 1) { Empleo[i] = 400; } // paramédico
        			else if(PlayerInfo[i][Rank] == 2) { Empleo[i] = 600; } // bombero
           			else if(PlayerInfo[i][Rank] == 3) { Empleo[i] = 700; } // coordinador de bomberos
              		else if(PlayerInfo[i][Rank] == 4) { Empleo[i] = 900; } // doctor
                	else if(PlayerInfo[i][Rank] == 5) { Empleo[i] = 1000; } // jefe de hospital
                }
                if(PlayerInfo[i][Faction] == 3 )
				{
    				if(PlayerInfo[i][Rank] == 1) { Empleo[i] = 250; } // becario
        			else if(PlayerInfo[i][Rank] == 2) { Empleo[i] = 500; } // periodista
           			else if(PlayerInfo[i][Rank] == 3) { Empleo[i] = 1000; } // director
              	}
          		if(0 < PlayerInfo[i][Job] < 8) { Empleo[i] = 100; } // All jobs except Criminal.
            	new Pago = Empleo[i];
            	new impuestos = 0;
				new key = PlayerInfo[i][HouseKey];
			    if(key != 0)
			    {
					if(strcmp(playername2, House[key][Owner], true) == 0)
					{
						impuestos += 10;
						House[key][Time]=0;
					}
			    }
			    if(PlayerInfo[i][VehicleKey]) { impuestos += 10; }
			    if(PlayerInfo[i][VehicleKey2]) { impuestos += 10; }
				new negocio = 0;
				if(PlayerInfo[i][BusinessKey]!=0)
				{
				    negocio = 200;
				}
            	//-----
				PlayerInfo[i][Bank] = account+100+Pago-impuestos+negocio;
				SendClientMessage(i, COLOR_LIGHTYELLOW, "|___ PAY DAY ___|");
    	        SendClientMessage(i, COLOR_WHITE, "Payment: 100");
				format(string, sizeof(string), "~y~payday~n~~w~check");
				GameTextForPlayer(i, string, 5000, 1);
				PlayerInfo[i][Hours] += 1;
				if(0 < PlayerInfo[i][Faction] < 4 || 0 < PlayerInfo[i][Job] < 8)
			    {
    	            format(string, sizeof(string), "Wage: %d", Pago);
					SendClientMessage(i, COLOR_LIGHTGREEN, string);
	    		}
	    		if(PlayerInfo[i][BusinessKey]!=0)
				{
				    SendClientMessage(i, COLOR_LIGHTYELLOW,"Business earnings: 200");
				}
			    if(impuestos > 0)
			    {
				    format(string, sizeof(string), "Taxes: %d", impuestos);
					SendClientMessage(i, COLOR_WHITE, string);
				}
				SendClientMessage(i, COLOR_WHITE, "|--------------------------------------|");
				format(string, sizeof(string), "  Old balance: %d", account);
				SendClientMessage(i, COLOR_GREY, string);
				format(string, sizeof(string), "  New balance: $ %d", PlayerInfo[i][Bank]);
				SendClientMessage(i, COLOR_WHITE, string);
				if(PlayerInfo[i][Prison]>0)
				{
				    PlayerInfo[i][Prison]-=1;
				    if(PlayerInfo[i][Prison]==0)
					{
					    SendClientMessage(i,COLOR_LIGHTYELLOW,"[Jailer] You are now free, be a better citizen.");
					    SetPlayerPos(i,1797.8315,-1578.8566,14.0901);
						SetPlayerInterior(i,0);
						SetPlayerVirtualWorld(i, 0);
					}
					else
					{
					    format(string, sizeof(string), "[Jailer] You still have to stay here for %d 'paydays'.", PlayerInfo[i][Prison]);
						SendClientMessage(i, COLOR_LIGHTYELLOW, string);
					}
				}
				SaveAccount(i, PlayerInfo[i][Password]);
				for(new h = 0; h < sizeof(House); h++)
				{
				    if(House[h][Seed]>=3 && House[h][Seed]<20)
				    {
				        House[h][Seed]+=1;
				    }
				    if(h!=0 && House[h][Owned]==1)
				    {
				        House[h][Time]+=1;
				        if(House[h][Time] > 720) // desahucio
				        {
				            strmid(House[h][Owner], "na", 0, strlen("na"), 255);
				            SendClientMessageToAll(BALLAS_COLOR, "[ADVERTISEMENT] Due to non-payment, a house has been seized by the State and is for sale now.");
				            House[h][Owned]=0;
				            House[h][Seed]=0;
				            House[h][Locked]=1;
				        }
				    }
				}
				for(new h = 0; h < sizeof(Business); h++)
				{
				    if(h!=0 && Business[h][Owned] == 1)
				    {
				        Business[h][Time]+=1;
				        if(Business[h][Time] > 720) // desahucio
				        {
				            strmid(Business[h][Owner], "na", 0, strlen("na"), 255);
				            SendClientMessageToAll(BALLAS_COLOR, "[ADVERTISEMENT] Due to non-payment, a store has been seized by the State and is for sale now.");
				            Business[h][Owned]=0;
				        }
				    }
				}
				for(new h = 0; h < sizeof(Vehicle); h++)
				{
				    if(Vehicle[h][Comprado]==1 && Vehicle[h][Tiempo] < 5)
				    {
				        Vehicle[h][Tiempo]+=1;
				        if(Vehicle[h][Tiempo]==5)
				        {
							new idBorrar=EliminarCoche(h);
							idBorrar+=51;
							DestroyVehicle(idBorrar);
							if(idBorrar==Mision[i])
							{
							    SendClientMessage(i, COLOR_LIGHTRED,"[Mobster] I am no longer interested in the vehicle I asked you for.");
							}
				        }
				    }
				}
				if(PlayerInfo[i][Hours] == PlayerInfo[i][Level] * 10)
				{
				    SendClientMessage(i, COLOR_YELLOW,"(( You level up! )).");
				    PlayerInfo[i][Level] += 1;
				    SetPlayerScore(i,PlayerInfo[i][Level]);
				}
				SaveThings();
			}
		}
	}
	return 1;
}

public SyncUp()
{
	SyncTime();
}
public SyncTime()
{
	new tmphour;
	new tmpminute;
	new tmpsecond;
	gettime(tmphour, tmpminute, tmpsecond);
	FixHour(tmphour);
	tmphour = shifthour;
	if ((tmphour > ghour) || (tmphour == 0 && ghour == 23))
	{
		ghour = tmphour;
		PayDay();
		if (realtime)
		{
			SetWorldTime(tmphour);
		}
	}
}
public FixHour(hour)
{
	hour = timeshift+hour;
	if (hour < 0)
	{
		hour = hour+24;
	}
	else if (hour > 23)
	{
		hour = hour-24;
	}
	shifthour = hour;
	return 1;
}

public DrugEffectGone(playerid)
{
	if(IsPlayerConnected(playerid))
	{
	    if(UsingDrugs[playerid] > 0)
	    {
	    	SetPlayerWeather(playerid, DefaultWeather);
	    	GameTextForPlayer(playerid, "~w~Drug effects ~p~wore off", 3000, 1);
	    	SetPlayerDrunkLevel(playerid, 0);
	    	UsingDrugs[playerid] = 0;
		}
	}
}

public GoHospital(playerid)
{
	if(IsPlayerConnected(playerid))
	{
	    if(PlayerInfo[playerid][Prison] > 0)
	    {
	        SetPlayerInterior(playerid,0);
	    	SetPlayerVirtualWorld(playerid, 1);
	    	SetPlayerPos(playerid, 1767.1479,-1549.7961,-10.7027);
	    	PlayerInfo[playerid][Dead] = 0;
	    	SetTimerEx("Descongelacion",1000,0,"i",playerid);
	    }
	    else if(PlayerInfo[playerid][Dead] == 1)
	    {
	    	SendClientMessage(playerid, COLOR_LIGHTBLUE, "(( You can spawn at the /hospital for a $500 fee. But if you're saved by paramedics there's no cost )).");
	    	Hospital[playerid] = 1;
		}
	}
}

public SendFamilyMessage(family, color, string[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
		    if(PlayerInfo[i][Faction] == family)
		    {
					SendClientMessage(i, color, string);
			}
		}
	}
}
public SendAlertMessage(family, color, string[],Float:x, Float:y, Float:z)
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
		    if(PlayerInfo[i][Faction] == family)
		    {
				SendClientMessage(i, color, string);
				SetPlayerCheckpoint(i, x, y, z, 5);
			}
		}
	}
}
public SendJobMessage(job, color, string[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
		    if(PlayerInfo[i][Job] == job)
		    {
				SendClientMessage(i, color, string);
			}
			if(job == 7 && 10 <= PlayerInfo[i][BusinessKey] <= 14)
			{
			    SendClientMessage(i, color, string);
			}
		}
	}
}

public PlayerToPoint(Float:radi, playerid, Float:x, Float:y, Float:z)
{
    if(IsPlayerConnected(playerid))
	{
		new Float:oldposx, Float:oldposy, Float:oldposz;
		new Float:tempposx, Float:tempposy, Float:tempposz;
		GetPlayerPos(playerid, oldposx, oldposy, oldposz);
		tempposx = (oldposx -x);
		tempposy = (oldposy -y);
		tempposz = (oldposz -z);
		if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi)))
		{
			return 1;
		}
	}
	return 0;
}
public PlayerToPointStripped(Float:radi, playerid, Float:x, Float:y, Float:z, Float:curx, Float:cury, Float:curz)
{
    if(IsPlayerConnected(playerid))
	{
		new Float:tempposx, Float:tempposy, Float:tempposz;
		tempposx = (curx -x);
		tempposy = (cury -y);
		tempposz = (curz -z);
		if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi))) return 1;
	}
	return 0;
}

Bicicletas(vehid)
{
	if(GetVehicleModel(vehid) == 509 || GetVehicleModel(vehid) == 481 || GetVehicleModel(vehid) == 510)
	{
		return 1;
	}
	return 0;
}

public StartingTheVehicle(playerid)
{
    if(IsPlayerConnected(playerid))
    {
        if(IsPlayerInAnyVehicle(playerid))
        {
    		new sendername[MAX_PLAYER_NAME];
    		new playerveh = GetPlayerVehicleID(playerid);
      		TogglePlayerControllable(playerid, true);
        	GetPlayerName(playerid, sendername, sizeof(sendername));
         	new veh = GetPlayerVehicleID(playerid);
          	new engine,lights,alarm,doors,bonnet,boot,objective;
           	GetVehicleParamsEx(veh,engine,lights,alarm,doors,bonnet,boot,objective);
            SetVehicleParamsEx(veh,VEHICLE_PARAMS_ON,lights,alarm,doors,bonnet,boot,objective);
            Motor[playerveh] = 1;
        }
    }
}

public VehicleLights(playerid, vehicleid)
{
  	new engine, lights, alarm, doors, bonnet, boot, objective;
  	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
  	if(lights == VEHICLE_PARAMS_ON || lights == VEHICLE_PARAMS_UNSET)
  	{
    	SetVehicleParamsEx(vehicleid, engine, VEHICLE_PARAMS_OFF, alarm, doors, bonnet, boot, objective);
  	}
  	else if(lights == VEHICLE_PARAMS_OFF)
  	{
    	SetVehicleParamsEx(vehicleid, engine, VEHICLE_PARAMS_ON, alarm, doors, bonnet, boot, objective);
  	}
	return 1;
}

public Cierrepeaje1()
{
      MoveDynamicObject(Puertapeaje1, 65.339996337891, -1529.5, 4.8000001907349-0.0001, 0.0001, 0, 90, 90);
	  return 1;
}
public Cierrepeaje2()
{
      MoveDynamicObject(Puertapeaje2, 36.400001525879, -1533.8000488281, 5.0999999046326-0.0001, 0.0001, 0, 90, 270);
	  return 1;
}

public Descongelacion(playerid)
{
    TogglePlayerControllable(playerid, 1);
  	return 1;
}

public OtherTimer()
{
	new string[256];
    for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerConnected(i))
	    {
			if(Taximetro[i] > 0)
			{
	    		Taximetro[i] += 5;
			    format(string, sizeof(string), "~w~Taximeter: ~g~$ %d",Taximetro[i]);
			    GameTextForPlayer(i, string, 15000, 6);
			    if(Taximetro[i] == 10)
			    {
				    format(string, sizeof(string), "The taximeter has reached: $ %d.", Taximetro[i]);
	        		ProxDetector(8.0, i, string, COLOR_LIGHTBLUE,COLOR_LIGHTBLUE,COLOR_LIGHTBLUE,COLOR_LIGHTBLUE,COLOR_LIGHTBLUE);
        		}
        		else if(Taximetro[i] > 50)
			    {
				    format(string, sizeof(string), "The taximeter has reached: $ %d.", Taximetro[i]);
	        		ProxDetector(8.0, i, string, COLOR_LIGHTBLUE,COLOR_LIGHTBLUE,COLOR_LIGHTBLUE,COLOR_LIGHTBLUE,COLOR_LIGHTBLUE);
        		}
			}
			if(PlayerToPoint(1.0, i,1797.8315,-1578.8566,14.0901))
			{
                GameTextForPlayer(i, "~w~Federal ~y~Prison", 5000, 3);
			}
			else if(PlayerToPoint(1.0, i,1219.2954,-1812.5404,16.5938) && pTest[i] == 0)
			{
                GameTextForPlayer(i, "~w~Driving licence ~r~/exam ~n~~w~Price: $~g~500", 5000, 3);
			}
			else if(PlayerToPoint(1.0, i,405.8781,-1724.5875,8.6603))
			{
                GameTextForPlayer(i, "~y~/repair ~n~~n~~w~Price: $~g~1500", 5000, 3);
			}
		}
	}
	return 1;
}

stock Localizando(const array[], length, element, llave)
{
    for(new i; i < length; i++)
        if(array[i] == element)
        {
            Gas[i+51]=100;
            Carros[i]=llave;
            return true;
		}
    return false;
}

stock EliminarCoche(id) // id en el fichero de coches
{
	new carro=id+51;
	for(new i; i < 20; i++)
	{
	    if(Carros[i]==carro)
	    {
			Carros[i]=0;
	        return i; // espacio que ocupa en el array Carros
	    }
	}
	return false;
}

public OnPlayerModelSelection(playerid, response, listid, modelid)
{
    new string[256];
	if(listid == carslist)
    {
    	if(response)
        {
            for(new i = 0; i < sizeof(Dealership); i++)
		    {
		        if(Dealership[i][0] == modelid)
		        {
	                format(string, sizeof(string), "[Dealership] %s: $ %d.", Dealership[i][2],Dealership[i][1]);
					SendClientMessage(playerid, COLOR_LIGHTYELLOW, string);
				}
			}
        }
    }
    if(listid == skinlist)
	{
		if(response)
		{
			new llave = NegVw[playerid];
			SendClientMessage(playerid, COLOR_WHITE, "[Shop assistant] You look well in your new outfit, the price is 20 dollars.");
			SetPlayerSkin(playerid, modelid);
			PlayerInfo[playerid][Skin] = modelid;
			GivePlayerMoney(playerid, -20);
			Business[llave][Money] += 20;
			Business[llave][Products] -= 1;
			TogglePlayerControllable(playerid, 1);
		}
		else SendClientMessage(playerid, COLOR_GREY, "You left the clothes catalogue.");
		TogglePlayerControllable(playerid, 1);
		return 1;
	}
	if(listid == skinlistmujer)
	{
		if(response)
		{
			new llave = NegVw[playerid];
			SendClientMessage(playerid, COLOR_WHITE, "[Shop assistant] You look well in your new outfit, the price is 20 dollars.");
			SetPlayerSkin(playerid, modelid);
			PlayerInfo[playerid][Skin] = modelid;
			GivePlayerMoney(playerid, -20);
			Business[llave][Money] += 20;
			Business[llave][Products] -= 1;
			TogglePlayerControllable(playerid, 1);
		}
		else SendClientMessage(playerid, COLOR_GREY, "You left the clothes catalogue.");
		return 1;
	}
	return 1;
}

stock GenerateVehicle(playerid, IdAuto )
{
    new sendername[MAX_PLAYER_NAME];
    new id = -1;
    id = BuscarIDMasBajo();
    if(id == -1) return SendClientMessage(playerid, COLOR_LIGHTRED, "[Dealership] We ran out of vehicles, my apologies.");
    new cajones=0;
    for(new i = 0; i <20; i++)
    {
		if(Carros[i]==0)
		{
		    cajones+=1;
		}
    }
    if(cajones==0)
	{
	    SendClientMessage(playerid, COLOR_LIGHTRED, "(( There are many private vehicles spawned in the server, try it later )).");
	    return 1;
	}
    Vehicle[id][Comprado] = 1;
    GetPlayerName(playerid, sendername, sizeof(sendername));
    strmid(Vehicle[id][Dueno], sendername, 0, strlen(sendername), 999);
    new string[15],
    vehicle = CreateVehicle(IdAuto, 529.0169,-1283.3954,17.2422,0,1,1,0);
    format(string, sizeof(string), "%s", Vehicle[id][Matricula]);
    SetVehicleNumberPlate(vehicle, string);
    Vehicle[id][Modelo] = IdAuto;
    Vehicle[id][Tiempo] = 0;
    Vehicle[id][Maletero]=0;
    Vehicle[id][MaleteroCantidad]=0;
    Vehicle[id][ColorUno]=1;
    Vehicle[id][Cerradura]=0;
    SendClientMessage(playerid, COLOR_LIGHTGREEN, "[Dealership] Your new vehicle is right there, its alarm is included in the price. Enjoy.");
    if(PlayerInfo[playerid][VehicleKey] == 0)
	{
		PlayerInfo[playerid][VehicleKey] = id+51;
		SaveThings();
		for(new i = 0; i < 20; i++)
		{
			if(Carros[i] == 0)
			{
			    Carros[i] = PlayerInfo[playerid][VehicleKey];
			    Gas[i+51] = 100;
			    return 1;
			}
		}
	}
    else if(PlayerInfo[playerid][VehicleKey2] == 0)
	{
		PlayerInfo[playerid][VehicleKey2] = id+51;
		SaveThings();
		for(new i = 0; i < 20; i++)
		{
			if(Carros[i] == 0)
			{
			    Carros[i] = PlayerInfo[playerid][VehicleKey2];
			    Gas[i+51] = 100;
			    return 1;
			}
		}
	}
    return 1;
}

BuscarIDMasBajo()
{
    for(new v = 0; v < 10; v++)
    {
        if(Vehicle[v][Comprado] == 0)
        {
            return v;
        }
    }
    return -1;
}

LoopingAnim(playerid,animlib[],animname[], Float:Speed, looping, lockx, locky, lockz, lp)
{
    ApplyAnimation(playerid, animlib, animname, Speed, looping, lockx, locky, lockz, lp);
    DoingAnimation[playerid] = 1;
}

public ResetObject(playerid)
{
    if(PlayerInfo[playerid][Back] == 3) { SetPlayerAttachedObject(playerid, BackSlot, 357, 1, -0.060921, -0.161673, 0.000000, 0.000000, 35.362735, 0.000000); }
    else if(PlayerInfo[playerid][Back] == 4) { SetPlayerAttachedObject(playerid, BackSlot, 349, 1, -0.060921, -0.154673, 0.000000, 0.000000, 35.362735, 0.000000); }
    else if(PlayerInfo[playerid][Back] == 5) { SetPlayerAttachedObject(playerid, BackSlot, 358, 1, -0.060921, -0.143673, 0.000000, 0.000000, 35.362735, 0.000000); }
    else if(PlayerInfo[playerid][Back] == 7) { SetPlayerAttachedObject(playerid, BackSlot, 353, 1, -0.060921, -0.143673, 0.000000, 0.000000, 35.362735, 0.000000); }
    else if(PlayerInfo[playerid][Back] == 8) { SetPlayerAttachedObject(playerid, BackSlot, 355, 1, -0.060921, -0.141673, 0.000000, 0.000000, 35.362735, 0.000000); }
    else if(PlayerInfo[playerid][Back] == 9) { SetPlayerAttachedObject(playerid, BackSlot, 356, 1, -0.099681, -0.133408, 0.000000, 1.027592, 19.667785, 0.000000); }
    // Weapon and SAMP object ids.
    new weaObj[][] = {
		{0, 0},
		{22, 346},
		{24, 348},
		{33, 357},
		{25, 349},
		{34, 358}, // 5: Sniper.
		{28, 352},
		{29, 353},
		{30, 355},
		{31, 356},
		{41, 365}, // 10: Spray.
		{42, 366},
		{43, 0}, // 12: Camera.
		{18, 0}, // 13: Molotov.
		{4, 335},
		{6, 337}, // 15: Shovel.
		{5, 336},
		{3, 334}
	};
	new objId;
	objId = PlayerInfo[playerid][Hand];
    GivePlayerWeapon(playerid, weaObj[objId][0], PlayerInfo[playerid][HandAmount]);
    SetPlayerAttachedObject(playerid,0,weaObj[objId][1],6,0.0,0.0,0.0,0.0,0.0,0.0,1.0,1.0,1.0);
	switch(PlayerInfo[playerid][Hand])
	{
	    case 27: SetPlayerAttachedObject(playerid,0,2769,6,0.059999,0.079999,0.0,0.0,90.0,0.0,1.0,1.0,1.0);
	    case 28: SetPlayerAttachedObject( playerid, 0, 2703, 6, 0.000000, 0.039999, 0.000000, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000 );
	    case 29: SetPlayerAttachedObject( playerid, 0, 1582, 6, 0.000000, -0.289999, 0.000000, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000 );
	    case 30: SetPlayerAttachedObject( playerid, 0, 2702, 6, 0.100000, 0.000000, 0.100000, 90.000000, 180.000000, 0.000000, 1.000000, 1.000000, 1.000000 );
	    case 31: SetPlayerAttachedObject( playerid, 0, 1666, 6, 0.050000, 0.039999, 0.009999, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000 );
	    case 32: SetPlayerAttachedObject( playerid, 0, 1546, 6, 0.039999, 0.059999, 0.000000, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000 );
	    case 33: SetPlayerAttachedObject( playerid, 0, 1543, 6, 0.070000, 0.028000, -0.239800, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000 );
	    case 34: SetPlayerAttachedObject(playerid, 0, 330, 6);
	    case 35: SetPlayerAttachedObject(playerid, 0 , 1210, 6, 0.3, 0.1, 0, 0, -90, 0);
	    case 36: SetPlayerAttachedObject(playerid,0,1650,6);
	    case 37: SetPlayerAttachedObject(playerid, 0, 18634, 6, 0.045389, -0.019335, -0.246956, 0.000000, 91.442123, 85.389228, 0.971265, 1.000000, 1.000000 );
	    case 38: SetPlayerAttachedObject(playerid, 0, 18645, 6);
	    case 39: { SetPlayerAttachedObject(playerid,0,1576,1,0.0,0.4,0.0,0.0,95.0,0.0,1.0,1.0,1.0); CarryingBox[playerid] = 1; }
	    case 40, 41: { SetPlayerAttachedObject(playerid,0,2969,1,0.15,0.4,0.0,0.0,100.0,0.0,1.0,1.0,1.0); CarryingBox[playerid] = 1; }
	    case 42, 43, 44: { SetPlayerAttachedObject(playerid,0,2041,1,0.23,0.5,-0.05,0.0,100.0,90.0,1.0,1.0,1.0); CarryingBox[playerid] = 1; }
	    case 45: { SetPlayerAttachedObject(playerid,0,1578,1,0.0,0.4,0.0,0.0,95.0,0.0,1.0,1.0,1.0); CarryingBox[playerid] = 1; }
	    case 46: { SetPlayerAttachedObject(playerid,0,1575,1,0.0,0.4,0.0,0.0,95.0,0.0,1.0,1.0,1.0); CarryingBox[playerid] = 1; }
	    case 48: SetPlayerAttachedObject(playerid,0,1485,6,0.0,0.0,0.0,0.0,0.0,0.0,1.0,1.0,1.0);
	    case 50: SetPlayerAttachedObject(playerid, 0, 3027, 6, 0.100000, 0.000000, 0.019999, 60.000000, 70.000000, 90.000000, 1.000000, 1.000000, 1.000000 );
	    case 51: SetPlayerAttachedObject(playerid, 0, 1852, 6);
	}
	if(CarryingBox[playerid]==1) { LoopingAnim(playerid, "CARRY", "crry_prtial",4.1,0,1,1,1,1); }
	return 1;
}

stock NombreEx(playerid)
{
	new string[24];
	GetPlayerName(playerid,string,24);
	new str[24];
	strmid(str,string,0,strlen(string),24);
	for(new i = 0; i < MAX_PLAYER_NAME; i++)
	{
		if (str[i] == '_') str[i] = ' ';
	}
	return str;
}

public ProxDetector(Float:radi, playerid, string[],col1,col2,col3,col4,col5)
{
	if(PlayerInfo[playerid][Admin] != 2)
	{
		new Float:posx, Float:posy, Float:posz;
		new Float:oldposx, Float:oldposy, Float:oldposz;
		new Float:tempposx, Float:tempposy, Float:tempposz;
		GetPlayerPos(playerid, oldposx, oldposy, oldposz);
		for(new i = 0; i < MAX_PLAYERS; i++)
		{
			if(PlayerInfo[playerid][Admin] != 2 && (GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i)))
			{
				if(!BigEar[i])
				{
					GetPlayerPos(i, posx, posy, posz);
					tempposx = (oldposx -posx);
					tempposy = (oldposy -posy);
					tempposz = (oldposz -posz);
					if (((tempposx < radi/16) && (tempposx > -radi/16)) && ((tempposy < radi/16) && (tempposy > -radi/16)) && ((tempposz < radi/16) && (tempposz > -radi/16)))
					{
						SendClientMessage(i, col1, string);
					}
					else if (((tempposx < radi/8) && (tempposx > -radi/8)) && ((tempposy < radi/8) && (tempposy > -radi/8)) && ((tempposz < radi/8) && (tempposz > -radi/8)))
					{
						SendClientMessage(i, col2, string);
					}
					else if (((tempposx < radi/4) && (tempposx > -radi/4)) && ((tempposy < radi/4) && (tempposy > -radi/4)) && ((tempposz < radi/4) && (tempposz > -radi/4)))
					{
						SendClientMessage(i, col3, string);
					}
					else if (((tempposx < radi/2) && (tempposx > -radi/2)) && ((tempposy < radi/2) && (tempposy > -radi/2)) && ((tempposz < radi/2) && (tempposz > -radi/2)))
					{
						SendClientMessage(i, col4, string);
					}
					else if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi)))
					{
						SendClientMessage(i, col5, string);
					}
				}
				else
				{
					SendClientMessage(i, col1, string);
				}
			}
		}
	}//not connected
	return 1;
}

public ProxDetectorS(Float:radi, playerid, targetid)
{
    if(IsPlayerConnected(playerid)&&IsPlayerConnected(targetid))
	{
		new Float:posx, Float:posy, Float:posz;
		new Float:oldposx, Float:oldposy, Float:oldposz;
		new Float:tempposx, Float:tempposy, Float:tempposz;
		GetPlayerPos(playerid, oldposx, oldposy, oldposz);
		GetPlayerPos(targetid, posx, posy, posz);
		tempposx = (oldposx -posx);
		tempposy = (oldposy -posy);
		tempposz = (oldposz -posz);
		if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi)))
		{
			return 1;
		}
	}
	return 0;
}

strtok(const string[], &index)
{
    new length = strlen(string);
    while ((index < length) && (string[index] <= ' '))
    {
        index++;
    }

    new offset = index;
    new result[20];
    while ((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1)))
    {
        result[index - offset] = string[index];
        index++;
    }
    result[index - offset] = EOS;
    return result;
}

ReturnUser(text[], playerid = INVALID_PLAYER_ID)
{
    new pos = 0;
    while (text[pos] < 0x21) // Strip out leading spaces
    {
        if (text[pos] == 0) return INVALID_PLAYER_ID; // No passed text
        pos++;
    }
    new userid = INVALID_PLAYER_ID;
    if (IsNumeric(text[pos])) // Check whole passed string
    {
        userid = strval(text[pos]);
        if (userid >=0 && userid < MAX_PLAYERS)
        {
            if(!IsPlayerConnected(userid))
            {
                userid = INVALID_PLAYER_ID;
            }
            else
            {
                return userid;
            }
        }
    }
    new len = strlen(text[pos]);
    new count = 0;
    new name[MAX_PLAYER_NAME];
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (IsPlayerConnected(i))
        {
            GetPlayerName(i, name, sizeof (name));
            if (strcmp(name, text[pos], true, len) == 0)
            {
				if (len == strlen(name))
				{
					return i;
                }
				else
				{
    				count++;
                    userid = i;
                }
			}
		}
	}
	if (count != 1)
    {
		if (playerid != INVALID_PLAYER_ID)
        {
			if (count)
	        {
				SendClientMessage(playerid, 0xFF0000AA, "Multiple users found, please narrow search.");
	        }
			else
			{
				SendClientMessage(playerid, 0xFF0000AA, "No matching user found.");
			}
  		}
		userid = INVALID_PLAYER_ID;
	}
	return userid;
}

public BanLog(string[])
{
	new entry[256];
	format(entry, sizeof(entry), "%s\n",string);
	new File:hFile;
	hFile = fopen("ban.log", io_append);
	fwrite(hFile, entry);
	fclose(hFile);
}

public Lotto(number)
{
	new string[256];
	//new winner[MAX_PLAYER_NAME];
	format(string, sizeof(string), "[NOTICE] Lottery: The winning number of this edition is: %d.", number);
    SendClientMessageToAll(COLOR_GREEN, string);
    for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
		    if(PlayerInfo[i][LottoNumber] > 0)
		    {
			    if(PlayerInfo[i][LottoNumber] == number)
			    {
			        //GetPlayerName(i, winner, sizeof(winner));
					format(string, sizeof(string), "[NOTICE] Lottery: %s has won the award of 200,000 dollars, congratulations!", NombreEx(i));
					SendClientMessageToAll(COLOR_GREEN, string);
					SendClientMessage(i, COLOR_YELLOW, "[SMS] You have received money in your bank account.");
					PlayerInfo[i][Bank] += 200000;
			    }
			    else
			    {
			        SendClientMessage(i, COLOR_RED, "[SMS] Sorry, you have not won any award.");
			    }
			}
			PlayerInfo[i][LottoNumber] = 0;
		}
	}
	return 1;
}

public PayLog(string[])
{
	new entry[256];
	format(entry, sizeof(entry), "%s\n",string);
	new File:hFile;
	hFile = fopen("PayLog.log", io_append);
	fwrite(hFile, entry);
	fclose(hFile);
}

public ABroadCast(color,const string[],level)
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			if (PlayerInfo[i][Admin] >= level)
			{
				SendClientMessage(i, color, string);
				printf("%s", string);
			}
		}
	}
	return 1;
}

stock CreateObjeto(Float:x,Float:y,Float:z,Float:Angle,id,cantidad)
{
	for(new i = 0; i < sizeof(ObjetosInfo); i++)
 	{
		if(ObjetosInfo[i][objetoCreated] == 0)
 		{
 			ObjetosInfo[i][objetoCreated]=1;
 			ObjetosInfo[i][objetoX]=x;
 			ObjetosInfo[i][objetoY]=y;
 			ObjetosInfo[i][objetoZ]=z-0.75;
 			switch(id)
 			{
				case 31: ObjetosInfo[i][objetoObject] = CreateObject(1666, x, y, z-0.92, 0, 0, Angle+180); // water.
				case 32: ObjetosInfo[i][objetoObject] = CreateObject(1546, x, y, z-0.92, 0, 0, Angle+180); // soda.
				case 33: ObjetosInfo[i][objetoObject] = CreateObject(1543, x, y, z-0.95, 0, 0, Angle+180); // beer.
				case 36: ObjetosInfo[i][objetoObject] = CreateObject(1650, x, y, z-0.69, 0, 0, Angle+180); // gasoline can.
				default: ObjetosInfo[i][objetoObject] = CreateObject(18631,x, y, z-0.75, 0, 0, Angle+180);
			}
 			ObjetosInfo[i][objetoId] = id;
 			ObjetosInfo[i][objetoCantidad] = cantidad;
			return 1;
 		}
 	}
	return 0;
}
stock DeleteClosestObjeto(playerid)
{
	for(new i = 0; i < sizeof(VallasInfo); i++)
    {
		if(IsPlayerInRangeOfPoint(playerid, 2.0, ObjetosInfo[i][objetoX], ObjetosInfo[i][objetoY], ObjetosInfo[i][objetoZ]))
        {
        	if(ObjetosInfo[i][objetoCreated] == 1)
            {
                new string[256];
                PlayerInfo[playerid][Hand] = ObjetosInfo[i][objetoId];
                PlayerInfo[playerid][HandAmount] = ObjetosInfo[i][objetoCantidad];
				ObjetosInfo[i][objetoCreated]=0;
				ObjetosInfo[i][objetoX]=0.0;
				ObjetosInfo[i][objetoY]=0.0;
				ObjetosInfo[i][objetoZ]=0.0;
				DestroyObject(ObjetosInfo[i][objetoObject]);
				format(string, sizeof(string), "You have picked up %s.", Obje[PlayerInfo[playerid][Hand]]);
     			SendClientMessage(playerid, COLOR_GREEN, string);
				ResetObject(playerid);
				return 1;
 			}
 		}
 	}
	return 0;
}

stock CreateCono(Float:x,Float:y,Float:z,Float:Angle)
{
	for(new i = 0; i < sizeof(ConosInfo); i++)
 	{
		if(ConosInfo[i][conoCreated] == 0)
 		{
 			ConosInfo[i][conoCreated]=1;
 			ConosInfo[i][conoX]=x;
 			ConosInfo[i][conoY]=y;
 			ConosInfo[i][conoZ]=z-0.7;
 			ConosInfo[i][conoObject] = CreateObject(1238, x, y, z-0.625, 0, 0, Angle+180);
			return 1;
 		}
 	}
	return 0;
}
stock DeleteAllConos()
{
	for(new i = 0; i < sizeof(ConosInfo); i++)
 	{
		if(ConosInfo[i][conoCreated] == 1)
 		{
 			ConosInfo[i][conoCreated]=0;
 			ConosInfo[i][conoX]=0.0;
 			ConosInfo[i][conoY]=0.0;
 			ConosInfo[i][conoZ]=0.0;
 			DestroyObject(ConosInfo[i][conoObject]);
 		}
 	}
	return 0;
}
stock DeleteClosestCono(playerid)
{
	for(new i = 0; i < sizeof(ConosInfo); i++)
 	{
		if(IsPlayerInRangeOfPoint(playerid, 2.0, ConosInfo[i][conoX], ConosInfo[i][conoY], ConosInfo[i][conoZ]))
 		{
			if(ConosInfo[i][conoCreated] == 1)
 			{
 				ConosInfo[i][conoCreated]=0;
 				ConosInfo[i][conoX]=0.0;
 				ConosInfo[i][conoY]=0.0;
 				ConosInfo[i][conoZ]=0.0;
 				DestroyObject(ConosInfo[i][conoObject]);
				return 1;
 			}
		}
 	}
	return 0;
}
stock CreateValla(Float:x,Float:y,Float:z,Float:Angle)
{
	for(new i = 0; i < sizeof(VallasInfo); i++)
 	{
		if(VallasInfo[i][vallaCreated] == 0)
 		{
 			VallasInfo[i][vallaCreated]=1;
 			VallasInfo[i][vallaX]=x;
 			VallasInfo[i][vallaY]=y;
 			VallasInfo[i][vallaZ]=z-0.7;
 			VallasInfo[i][vallaObject] = CreateObject(1459, x, y, z-0.325, 0, 0, Angle+180);
			return 1;
 		}
 	}
	return 0;
}
stock DeleteClosestValla(playerid)
{
	for(new i = 0; i < sizeof(VallasInfo); i++)
    {
		if(IsPlayerInRangeOfPoint(playerid, 2.0, VallasInfo[i][vallaX], VallasInfo[i][vallaY], VallasInfo[i][vallaZ]))
        {
        	if(VallasInfo[i][vallaCreated] == 1)
            {
				VallasInfo[i][vallaCreated]=0;
				VallasInfo[i][vallaX]=0.0;
				VallasInfo[i][vallaY]=0.0;
				VallasInfo[i][vallaZ]=0.0;
				DestroyObject(VallasInfo[i][vallaObject]);
				return 1;
 			}
 		}
 	}
	return 0;
}

public IsAtGasStation(playerid)
{
	if(PlayerToPoint(9.0,playerid,1940.5851,-1772.3232,13.3906))
	{
  		return 1;
	}
	return 0;
}

IsNumeric(const string[])
{
    for (new i = 0, j = strlen(string); i < j; i++)
    {
        if (string[i] > '9' || string[i] < '0') return 0;
    }
    return 1;
}

public DKT1(playerid)
{
	if(PlayerToPoint(2.5, playerid,1219.2954,-1812.5404,16.5938))
	{
		ClearChatbox(playerid, 5);
	 	SendClientMessage(playerid, COLOR_GREEN, "Welcome to the driving licence exam.");
		SendClientMessage(playerid, COLOR_GREEN, " ");
	 	SendClientMessage(playerid, COLOR_GREEN, "There are 5 questions, and you cannot fail any single one, so stay focused.");
	 	SendClientMessage(playerid, COLOR_GREEN, "If you fail, you will not pay money, so do not worry.");
	 	SendClientMessage(playerid, COLOR_GREEN, " ");
	 	SendClientMessage(playerid, COLOR_GREY, "(( To give the answers, write the numbers in the normal chat, example: 2 )).");
		SetTimerEx("DKT2", 20000, 0, "d", playerid);
	}
}
public DKT2(playerid)
{
	if(PlayerToPoint(2.5, playerid,1219.2954,-1812.5404,16.5938))
	{
	    pTest[playerid] = 2;
		ClearChatbox(playerid, 6);
	 	SendClientMessage(playerid, COLOR_LIGHTRED, "|_________________________________| Question One |________________________________|");
		SendClientMessage(playerid, COLOR_WHITE, "When is it mandatory to stop and let other drivers pass?");
		SendClientMessage(playerid, COLOR_WHITE, " ");
		SendClientMessage(playerid, COLOR_WHITE, "1: When I feel generous.");
		SendClientMessage(playerid, COLOR_WHITE, "2: When my road encounters a pedestrian crossing.");
		SendClientMessage(playerid, COLOR_WHITE, "3: It depends only on the traffict light colour. If it is red, I stop.");
		SendClientMessage(playerid, COLOR_WHITE, "4: When I am in front of a blue traffic sign.");
		SendClientMessage(playerid, COLOR_LIGHTRED, "|_______________________________________________________________________________|");
	}
}
public DKT3(playerid)
{
    pTest[playerid] = 3;
	ClearChatbox(playerid, 5);
 	SendClientMessage(playerid, COLOR_LIGHTRED, "|_________________________________| Question Two |________________________________|");
	SendClientMessage(playerid, COLOR_WHITE, "Where can the vehicles be parked?");
	SendClientMessage(playerid, COLOR_WHITE, " ");
	SendClientMessage(playerid, COLOR_WHITE, "1: In parkings, and also between the pavement and the road.");
	SendClientMessage(playerid, COLOR_WHITE, "2: Only in private garages.");
	SendClientMessage(playerid, COLOR_WHITE, "3: Only in parkings.");
	SendClientMessage(playerid, COLOR_WHITE, "4: In parkings and private garages only.");
	SendClientMessage(playerid, COLOR_LIGHTRED, "|_______________________________________________________________________________|");
}
public DKT4(playerid)
{
    pTest[playerid] = 4;
	ClearChatbox(playerid, 5);
 	SendClientMessage(playerid, COLOR_LIGHTRED, "|_________________________________| Question Three |________________________________|");
	SendClientMessage(playerid, COLOR_WHITE, "What action is wrong?");
	SendClientMessage(playerid, COLOR_WHITE, " ");
	SendClientMessage(playerid, COLOR_WHITE, "1: When I have an accident, I help the injured person.");
	SendClientMessage(playerid, COLOR_WHITE, "2: When I see the traffic light orange from a far distance, I accelerate more.");
	SendClientMessage(playerid, COLOR_WHITE, "3: I pull over when police asks so by megaphone or sirens.");
	SendClientMessage(playerid, COLOR_WHITE, "4: If there are already people helping in an accident, I ignore them.");
	SendClientMessage(playerid, COLOR_LIGHTRED, "|_______________________________________________________________________________|");
}
public DKT5(playerid)
{
    pTest[playerid] = 5;
	ClearChatbox(playerid, 5);
	SendClientMessage(playerid, COLOR_LIGHTRED, "|_________________________________| Question Four |________________________________|");
	SendClientMessage(playerid, COLOR_WHITE, "In case of collision with other driver:");
	SendClientMessage(playerid, COLOR_WHITE, " ");
	SendClientMessage(playerid, COLOR_WHITE, "1: We say sorry to each other like civilised people and keep our way.");
	SendClientMessage(playerid, COLOR_WHITE, "2: We fight like uncivilised people.");
	SendClientMessage(playerid, COLOR_WHITE, "3: If it is my fault, I pay for the repair of the other vehicle, 800 dollars.");
	SendClientMessage(playerid, COLOR_WHITE, "4: I call police so that the other driver gets arrested.");
	SendClientMessage(playerid, COLOR_LIGHTRED, "|_______________________________________________________________________________|");
}
public DKT6(playerid)
{
    pTest[playerid] = 6;
	ClearChatbox(playerid, 5);
 	SendClientMessage(playerid, COLOR_LIGHTRED, "|_________________________________| Question Five |________________________________|");
	SendClientMessage(playerid, COLOR_WHITE, "In case of accident:");
	SendClientMessage(playerid, COLOR_WHITE, " ");
	SendClientMessage(playerid, COLOR_WHITE, "1: We order the other person to pay the repair of our vehicle.");
	SendClientMessage(playerid, COLOR_WHITE, "2: We call the army.");
	SendClientMessage(playerid, COLOR_WHITE, "3: We stay in the middle of the road until the ambulance shows up.");
	SendClientMessage(playerid, COLOR_WHITE, "4: We move our vehicles away if possible so that they don't stop the traffic.");
	SendClientMessage(playerid, COLOR_LIGHTRED, "|_______________________________________________________________________________|");
}

public LoadPhoneNumber()
{
	new arrCoords[1][64];
	new strFromFile2[256];
	new File: file = fopen("phoneCounter.ini", io_read);
	if (file)
	{
		fread(file, strFromFile2);
		split(strFromFile2, arrCoords, ',');
		PhoneNumberSystem[PhoneNumberCount] = strval(arrCoords[0]);
		fclose(file);
	}
	return 1;
}
public SavePhoneNumber()
{
	new coordsstring[256];
	format(coordsstring, sizeof(coordsstring), "%d", PhoneNumberSystem[PhoneNumberCount]);
	new File: file2 = fopen("phoneCounter.ini", io_write);
	fwrite(file2, coordsstring);
	fclose(file2);
	return 1;
}

public Fillup()
{
	for(new i=0; i<MAX_PLAYERS; i++)
   	{
	   	if(IsPlayerConnected(i))
	   	{
		    new VID;
		    new Nafta;
		    new string[256];
		    VID = GetPlayerVehicleID(i);
		    Nafta = GasMax - Gas[VID];
			if(Refueling[i] == 1)
		    {
		        Gas[VID] += Nafta;
		        format(string,sizeof(string),"* Vehicle filled up with %d litres for $ %d.", Nafta, Nafta * 2);
		    	SendClientMessage(i,COLOR_LIGHTBLUE,string);
				GivePlayerMoney(i, - Nafta * 2);
				Refueling[i] = 0;
		        if(GetPlayerVehicleID(i) < 51)
		    	{
			    	format(string,sizeof(string),"* %d litres filled up, you send the receipt to the boss.", Nafta);
				    SendClientMessage(i,COLOR_LIGHTGREEN,string);
				    GivePlayerMoney(i, Nafta * 2);
	    		}
		 	}
		}
	}
	return 1;
}

public CheckGas()
{
	new string[256];
	for(new i=0;i<MAX_PLAYERS;i++)
	{
    	if(IsPlayerConnected(i))
       	{
       	    if(GetPlayerState(i) == PLAYER_STATE_DRIVER)
       	    {
	       		new vehicle = GetPlayerVehicleID(i);
	        	if(Gas[vehicle] >= 1 && Motor[vehicle] == 1)
		   		{
		   		    if(Gas[vehicle] <= 10) { PlayerPlaySound(i, 1085, 0.0, 0.0, 0.0); }
	              	Gas[vehicle]--;
		   		}
	   			else
	           	{
		        	new playerveh = GetPlayerVehicleID(i);
					Motor[playerveh] = 0;
					Motor[GetPlayerVehicleID(i)] = 0;
					new veh = GetPlayerVehicleID(i);
                    new engine,lights,alarm,doors,bonnet,boot,objective;
                    GetVehicleParamsEx(veh,engine,lights,alarm,doors,bonnet,boot,objective);
                    SetVehicleParamsEx(veh,VEHICLE_PARAMS_OFF,lights,0,doors,bonnet,boot,objective);
				}
				if(gGas[i] == 1)
				{
  					format(string, sizeof(string), "~w~~n~~n~~n~~n~~n~~n~~n~~n~~n~Fuel:~r~ %d",Gas[vehicle]);
		      		GameTextForPlayer(i,string,15500,3);
		  		}
			}
    	}
	}
	return 1;
}

