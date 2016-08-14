import <QuestLib.ash>;
import <zlib.ash>;
import <Spookyraven Upstairs.ash>;
import <Pirate.ash>;
import <Level 02.ash>;

boolean spinWheel() {
	if(!have_item($item[crumbling wooden wheel]) && !have_item($item[tomb ratchet])) 
		return false;
	if(have_item($item[crumbling wooden wheel])) 
		manual_run_choice(929,1);
	else
		manual_run_choice(929,2);
	return true;
}

string[7] answer;
answer[0] = "b"; answer[1] = "a"; answer[2] = "n";
answer[3] = "a"; answer[4] = "n"; answer[5] = "a";
answer[6] = "s";

void tileSolver(string input) {
	matcher tileMap = create_matcher("tile\\w+\\.gif",visit_url("main.php"));
	int count=0;
	string row;
	int[7] tileNumber;
	while(find(tileMap)) {
		if(count%9==0) row = "";
		count+=1;
		if(group(tileMap).char_at(4)==answer[6-(count-1)/9])  tileNumber[6-(count-1)/9] = to_int(count%9)-1;
		row += group(tileMap).char_at(4) + " ";
		if(count%9==0) print_debug(row);
		if(count>63) abort("Failed parsing.");
	}
	for i from 0 upto 6 {
		print_debug("Tile "+ (tileNumber[i]+1) + ", link "+"tiles.php?action=jump&whichtile=" + tileNumber[i]);
		visit_url("tiles.php?action=jump&whichtile=" + tileNumber[i]);
		waitq(1);
	}
}

string hiddenTempleAdventure() {
	// the function must be run AFTER having the Nostril
	string page = visit_url(to_url($location[The Hidden Temple]));
	
	if(contains_text(page,"Combat")) {
		page = run_combat();
		return page;
	} else if(contains_text(page,"Hidden Heart")) { // && have_item($item[The Nostril of The Serpent])
		// beginning opening the way to the hidden city
		print_debug("Go to unconfusing button.");
		manual_run_choice(580,2);
		print_debug("Go to pikachulotal.");
		manual_run_choice(584,4);
		print_debug("Open the way.");
		manual_run_choice(580,1);
		print_debug("Choice raise hand.");
		manual_run_choice(123,2);
		page = visit_url("choice.php");
		print_debug("Parse the map and get your path.");
		tileSolver(page);
		print_debug("Do nothing to unlock.");
		page = manual_run_choice(125,3);
	} else {
		page = run_choice(page);
	}
	return page;
}

void checkForestChoice() {
	if(have_item($item[beehive]))
		set_choices(924,1);
	else
		set_choices(924,3);
}

void checkTempleChoice() {
	if(have_item($item[The Nostril of The Serpent])) {
		set_choices(579,3);
		set_choices(580,2);
	}
	else {
		set_choices(579,2);
	}
	set_choices(584,4);
	set_choices(581,3);
}

boolean blackMarketOpened() {
	return contains_text(visit_url("woods.php"),"blackmarket.gif");
}

void helpWithBlackMarket() {
	if (!have_familiar($familiar[Reassembled Blackbird]))
	{
		if(have_item($item[sunken eyes]) && have_item($item[broken wings])) {
			create(1,$item[reassembled blackbird]);
			use(1,$item[reassembled blackbird]);
			use_familiar($familiar[Reassembled Blackbird]);
		}
	}
	checkForestChoice();
}

void DiaryQuest()
{
	if (!have_item($item[your father's MacGuffin diary])) {
		if (!blackMarketOpened()) {
			set_backup_state();
			set_choices(923,1);
			set_choices(1018,1);
			set_choices(1019,1);

			if(have_familiar($familiar[Reassembled Blackbird])){
				use_familiar($familiar[Reassembled Blackbird]);
			}
			print_goal("Search for black market.");
			fulfill_condition("blackMarketOpened","helpWithBlackMarket",$location[The Black Forest]);
			get_backup_state();
		} else {
			print_goal_complete("Path to Black Market already opened.");
		}

		if (contains_text(visit_url("shop.php?whichshop=blackmarket"),"forged identification documents")) {
			if(!buy(1, $item[forged identification documents]))
				abort("Cannot buy forged id doc.");
		}

		if (have_item($item[forged identification documents])) {
			if(!have_item($item[your father's MacGuffin diary])) {
				if (my_adventures() < 3) {
					abort("Ran out of adventures.");
				}
				if (my_primestat() == $stat[muscle]) {
					set_choices(793,1);
				} else if (my_primestat() == $stat[mysticality]) {
					set_choices(793,2);
				} else {
					set_choices(793,3);
				}
				adv1($location[The Shore\, Inc. Travel Agency]);
			}
		}

		if (have_item($item[your father's MacGuffin diary])) {
			visit_url("diary.php?textversion=1");
		} else {
			abort("Failed to retrieve your father's MacGuffin diary.");
		}
	} else {
		visit_url("diary.php?textversion=1");
	}
}

boolean hiddenCityOpened() {
	return contains_text(visit_url("woods.php"),"hiddencitylink.gif");
}

void TempleQuest() 
{
	if(!contains_text(visit_url("woods.php"),"temple.gif")) {
		OpenTemple();
	} 
	if(!hiddenCityOpened()) {
		if(!have_item($item[The Nostril of The Serpent]) && !user_confirm("Did you acquired the Nostril?")) {
			print_goal("Searching for the nostril of the serpent.");
			obtain_item(1,$item[The Nostril of The Serpent],$location[The Hidden Temple]);
		}
		
		custom_fight("hiddenCityOpened","hiddenTempleAdventure");
	} else {
		print_quest_complete("The path to the Hidden City are cleared.");
	}
}

void HiddenCityQuest()
{
	if(contains_text(visit_url("questlog.php?which=1"),"Gotta Worship Them All")) {
		if(!have_item($item[antique machete]) && !have_equipped($item[antique machete])) {
			if(pulls_remaining()==0 || !user_confirm("Do you wish to pull the machete instead?")) {
				print_goal("Searching for machete");
				set_choices(789,2);
				obtain_item(1,$item[antique machete],$location[The Hidden Park]);
			} else {
				take_storage(1,$item[antique machete]);
			}
		}
		
		set_backup_state();
		equip($slot[weapon],$item[antique machete]);
		if(!contains_text(visit_url("place.php?whichplace=hiddencity"),"hc_apt.gif")){
			print_goal("Unlocking Apartment..");
			set_choices(781,1);
			while(get_last_encounter() != "Earthbound and Down") {
				while_abort();
				adv1($location[An Overgrown Shrine (Northwest)]);
			}
		}
		if(!contains_text(visit_url("place.php?whichplace=hiddencity"),"hc_office.gif")){
			print_goal("Unlocking Office..");
			set_choices(785,1);
			while(get_last_encounter() != "Air Apparent") {
				while_abort();
				adv1($location[An Overgrown Shrine (Northeast)]);
			}
		}
		if(!contains_text(visit_url("place.php?whichplace=hiddencity"),"hc_hospital.gif")){
			print_goal("Unlocking Hospital..");
			set_choices(783,1);
			while(get_last_encounter() != "Water You Dune") {
				while_abort();
				adv1($location[An Overgrown Shrine (Southwest)]);
			}
		}
		if(!contains_text(visit_url("place.php?whichplace=hiddencity"),"hc_bowling.gif")){
			print_goal("Unlocking Bowling Alley..");
			set_choices(787,1);
			while(get_last_encounter() != "Fire When Ready") {
				while_abort();
				adv1($location[An Overgrown Shrine (Southeast)]);
			}
		}
		get_backup_state();
		
		if(!have_item($item[stone triangle])) {
			print_goal("Searching for all spheres");
			if(!have_item($item[moss-covered stone sphere])) {
				print_goal("Searching for moss sphere.");
				while(!have_item($item[moss-covered stone sphere])) {
					if(have_effect($effect[Thrice-Cursed])>0) set_choices(780,1);
					else set_choices(780,3);
					while_abort();
					adventure(1,$location[The Hidden Apartment Building]);
				} 
			} else {
				print_goal_complete("Had moss sphere already.");
			}
			
			if(!have_item($item[crackling stone sphere])) {
				print_goal("Searching for crackling sphere.");
				while(!have_item($item[crackling stone sphere])) {
					// KolMafia automatically use the binder clips.
					if(have_item($item[McClusky file (complete)])) set_choices(786,1);
					else set_choices(786,2);
					while_abort();
					adventure(1,$location[The Hidden Office Building]);
				}
			} else {
				print_goal_complete("Had crackling sphere already.");
			}
			
			if(!have_item($item[scorched stone sphere])) {
				print_goal("Searching for scorched sphere.");
				set_choices(788,1);
				obtain_item(1,$item[scorched stone sphere],$location[The Hidden Bowling Alley]);
			} else {
				print_goal_complete("Had scorched sphere already.");
			}
			
			set_choices(784,1);
			if(!have_item($item[dripping stone sphere])) {
				print_goal("Searching for dripping sphere.");
				set_backup_state();
				if(!have_item($item[surgical apron]) && pulls_remaining()>0) {
					take_storage(1,$item[surgical apron]);
				}
				while(!have_item($item[dripping stone sphere])) {
					maximize_surgeon();
					while_abort();
					adventure(1,$location[The Hidden Hospital]);
				}
				get_backup_state();
			} else {
				print_goal_complete("Had dripping sphere already.");
			}
		}
		
		if(have_item($item[moss-covered stone sphere]) && have_item($item[crackling stone sphere])
		  && have_item($item[scorched stone sphere]) && have_item($item[dripping stone sphere])) {
			print_goal("Trading spheres for triangles..");
			adv1($location[An Overgrown Shrine (Northeast)]);
			adv1($location[An Overgrown Shrine (Southeast)]);
			adv1($location[An Overgrown Shrine (Northwest)]);
			adv1($location[An Overgrown Shrine (Southwest)]);
		}
		
		if(item_amount($item[stone triangle])==4) {
			set_backup_state();
			equip($slot[weapon],$item[antique machete]);
			set_choices(791,6);
			while(get_last_encounter()!="Legend of the Temple in the Hidden City") {
				adv1($location[A Massive Ziggurat]);
				while_abort();
			}
			set_choices(791,1);
			print_goal("Taking down the Protector Spectre.");
			get_backup_state();
			while_abort();
			adv1($location[A Massive Ziggurat]);
		} else abort("You(probably) have messed up the plan. Clean after yourself.");
		
	} else if(contains_text(visit_url("questlog.php?which=2"),"Gotta Worship Them All")) {
		print_quest_complete("You have already solve the Hidden City's mystery");
	} else {
		print_not_qualified("The Hidden City quest is unavailable.");
	}
}

void WorshipQuest()
{
	TempleQuest();
	HiddenCityQuest();
}

boolean cellarOpened() {
	return contains_text(visit_url("place.php?whichplace=manor1"), "sr_floor1_stairsdown.gif");
}

void LordSpookyravenQuest()
{
	SpookyravenUpstairs();

	if (contains_text(visit_url("questlog.php?which=1"),"In a Manor of Spooking"))
	{
		set_choices(921,1);
        if (!cellarOpened()) {
			print_goal("Finding the hidden switch to the cellar");
			fulfill_condition("cellarOpened",$location[The Haunted Ballroom]);
		}
		
		visit_url("place.php?whichplace=manor4&action=manor4_chamberwall");
		if(have_item($item[recipe: mortar-dissolving solution])) {
			print_goal("Seeing the hidden bomb-making recipe");
			if(have_item($item[Lord Spookyraven's spectacles])) {
				item subtitute = equipped_item($slot[acc3]);
				equip($slot[acc3],$item[Lord Spookyraven's spectacles]);
				use(1,$item[recipe: mortar-dissolving solution]);
				equip($slot[acc3],subtitute);
			} else {
				use(1,$item[recipe: mortar-dissolving solution]);
			}
		}

		if (contains_text(visit_url("questlog.php?which=1"),"blasting soda")) {
			set_backup_state();
			maximize_item();
			print_goal("Find Vinegar bottle");
			if(!have_item($item[bottle of Chateau de Vinegar])) {
				obtain_item(1,$item[bottle of Chateau de Vinegar],$location[The Haunted Wine Cellar]);
			}			
			
			print_goal("Find blasting soda");
			if(!have_item($item[blasting soda])) {
				obtain_item(1,$item[blasting soda],$location[The Haunted Laundry Room]);
			}
			get_backup_state();
		} else if (!contains_text(visit_url("questlog.php?which=1"),"-or-") &&
			contains_text(visit_url("questlog.php?which=1"),"loosening powder")){
			abort("Screw YOUR scavenger hunt. Find that spectacles.");
		}
		
		if (contains_text(visit_url("questlog.php?which=1"),"Cook up the explosive mixture")) {
			print_goal("Cook the inert bomb");
			create(1,$item[unstable fulminate]);
		}
		
		item currentW = equipped_item($slot[weapon]);
		item currentH = equipped_item($slot[off-hand]);
		if (contains_text(visit_url("questlog.php?which=1"),"Heat up the explosive mixture")) {
			print_goal("Heat the bomb up");
			if(have_equipped($item[unstable fulminate]) || equip($item[unstable fulminate])) {
				obtain_item(1,$item[wine bomb],$location[The Haunted Boiler Room]);
			} else {
				abort("Manually equip the unstable fulminate in hand and try again.");
			}
		}
		equip($slot[weapon],currentW);
		equip($slot[off-hand],currentH);
		
		if(have_item($item[wine bomb])) {
			print_goal("Blow your way open!");
			visit_url("place.php?whichplace=manor4&action=manor4_chamberwall");
		}
		
		if(contains_text(visit_url("questlog.php?which=1"),"confront Lord Spookyraven")) {
			print_goal("Smash the lord of this spooky manor.");
			adventure(1,$location[Summoning Chamber]);
		}
	} else if (contains_text(visit_url("questlog.php?which=2"),"In a Manor of Spooking")) {
		print_quest_complete("You have already completed In a Manor of Spooking.");
	} else {
		print_not_qualified("In a Manor of Spooking is not currently available.");
	}
}

string takeDogPhoto() {
	string page = visit_url(to_url($location[Inside The Palindome]));
	if(contains_text(page,"Combat")) {
		if(contains_text(page,"Racecar") && !have_item($item[photograph of a dog])) {
			page = throw_item($item[disposable instant camera]);
		} else {
			page = run_combat();
		}
	} else {
		page = run_choice(page);
	}
	return page;
}

boolean haveAllPhoto() {
	return have_item($item[photograph of a dog]) && have_item($item[photograph of God]) 
			&& have_item($item[photograph of a red nugget]) &&have_item($item[photograph of an ostrich egg]);
}

boolean haveVol1() {
	return have_item($item[I Love Me, Vol. I]);
}

boolean belowdecksOpened() {
	return contains_text(visit_url("cove.php"),"Belowdecks");
}

void PalindomeQuest()
{
	if (contains_text(visit_url("questlog.php?which=1"),"Of Mice and Shen") || contains_text(visit_url("questlog.php?which=1"),"Never Odd Or Even")) {
		if (!have_item($item[Talisman o' Namsilat]) && (equipped_amount($item[Talisman o' Namsilat])==0)) {
			set_backup_state();
			PirateQuest();
			if (available_amount($item[pirate fledges]) > 0) {
				if(have_item($item[pirate fledges]))
					equip($slot[acc3], $item[pirate fledges]);

				print_goal("Open Belowdecks");
				fulfill_condition("belowdecksOpened", $location[The Poop Deck]);

				if (belowdecksOpened()) {
					if (!have_item($item[Talisman o' Namsilat]))
					{
						print_goal("Search for snakehead charrrm");
						print_debug("The item are made automatically by KolMafia.");
						obtain_item(1, $item[Talisman o' Namsilat], $location[Belowdecks]);
					}
				}
			}
			get_backup_state();
		}

		set_backup_state();
		if (have_item($item[Talisman o' Namsilat])) {
			equip($slot[acc3], $item[Talisman o' Namsilat]);
		}
		if (contains_text(visit_url("plains.php"),"palinlink.gif")) {
			set_choices(129,1);
			if(!contains_text(visit_url("place.php?whichplace=palindome"),"Awkward")) {
				print_goal("Open door to Dr. Awkward's office.");
				custom_fight("haveVol1","takeDogPhoto");
				use(1,$item[I Love Me, Vol. I]);
			} else {
				print_goal_complete("Door to Dr. Awkward opened.");
			}
			
			if(!contains_text(visit_url("place.php?whichplace=palindome"),"Alarm")) {
				print_goal("Search for photo to meet Dr. Awkward.");
				custom_fight("haveAllPhoto","takeDogPhoto");
				
				if(!have_item($item[2 Love Me, Vol. 2])) {
					print_goal("Putting photo to place.");
					visit_url("place.php?whichplace=palindome&action=pal_droffice");
					visit_url("choice.php?pwd&whichchoice=872&option=1&photo1=2259&photo2=7264&photo3=7263&photo4=7265");
					if(have_item($item[Clan VIP Lounge key]) && user_confirm("Use the hottub to recuperate?"))
						visit_url("clan_viplounge.php?action=hottub");
					else if(user_confirm("Rest at campsite?")) 
						visit_url("campground.php?action=rest");
					else 
						res_abort("Please heal up and continue.");
				}
				use(1,$item[2 Love Me, Vol. 2]);
			} else {
				print_goal_complete("You now can meet Dr. Alarm.");
			}
			visit_url("place.php?whichplace=palindome&action=pal_mroffice");
			
			set_choices(131,1);
			if(contains_text(visit_url("questlog.php?which=1"),"wet stunt nut stew")) {
				if(pulls_remaining()>0 && storage_amount($item[wet stunt nut stew])>0 &&
					user_confirm("Pulling the wet stunt nut stew and bypass this part?")) {
					print_goal("Pull wet stunt nut stew");
					take_storage(1,$item[wet stunt nut stew]);
				} else {
					print_goal("Search for wet stunt nut stew");
					obtain_item(1, $item[wet stunt nut stew], $location[Inside the Palindome]);
				}
				visit_url("place.php?whichplace=palindome&action=pal_mroffice");
			}
			
			if(have_item($item[Mega Gem])) {
				print_goal("Avenging yourself!");
				equip($slot[acc2],$item[Mega Gem]);
				string page = visit_url("place.php?whichplace=palindome&action=pal_droffice");
				page=run_choice(page);
				page=run_combat();
			}
		}
		get_backup_state();
	} else if (contains_text(visit_url("questlog.php?which=2"),"Never Odd Or Even")) {
		print_quest_complete("You have already completed Never Odd Or Even.");
	} else {
		print_not_qualified("Never Odd Or Even is not currently available.");
	}
}

void DesertQuest()
{
    if (contains_text(visit_url("questlog.php?which=1"),"Just Deserts")) {
		cli_execute("conditions clear");

		if (!have_item($item[UV-resistant compass]) && (equipped_amount($item[UV-resistant compass])==0)) {
			if(user_confirm("Do you wish to find a UV-resistant compass?")) {
				if(!have_item($item[Shore Inc. Ship Trip Scrip])) {
					if (my_adventures() < 3) {
						abort("Ran out of adventures.");
					}
					if (my_primestat() == $stat[muscle]) {
						set_choices(793,1);
					} else if (my_primestat() == $stat[mysticality]) {
						set_choices(793,2);
					} else {
						set_choices(793,3);
					}
					adv1($location[The Shore\, Inc. Travel Agency]);
				}
				//buy(1,$item[UV-resistant compass]);
				cli_execute("/buy UV-resistant compass");
			}
		}
		
		set_backup_state();
		if(have_item($item[UV-resistant compass])) equip($item[UV-resistant compass]);
		
		if(!contains_text(visit_url("beach.php"),"oasis.gif")) {
			while_abort();
			adv1($location[The Arid\, Extra-Dry Desert]);
		}

		if(!contains_text(visit_url("beach.php"),"gnasir.gif")) {
			set_choices(805,1);
			while_abort();
			adventure(have_effect($effect[Ultrahydrated]), $location[The Arid\, Extra-Dry Desert]);
		}
		
		// searching for stone rose
		if((get_property("gnasirProgress").to_int() & 1) == 0 && !have_item($item[stone rose])) {
			obtain_item(1,$item[stone rose],$location[The Oasis]);
		}
		
		// acquiring can of black paint
		if((get_property("gnasirProgress").to_int() & 2) == 0 && !have_item($item[can of black paint])) {			
			buy(1,$item[can of black paint]);
		}

		int gnasirProgress = get_property("gnasirProgress").to_int();
		while(get_property("desertExploration").to_int()<100) {
			while_abort();
			if(have_effect($effect[Ultrahydrated])==0) adv1($location[The Oasis]);
			else adv1($location[The Arid\, Extra-Dry Desert]);
			gnasirProgress = get_property("gnasirProgress").to_int();
			if((gnasirProgress & 1) == 0 && have_item($item[stone rose])) {
				visit_url("place.php?whichplace=desertbeach&action=db_gnasir");
				visit_url("choice.php?pwd&whichchoice=805&option=2");
				visit_url("choice.php?pwd&whichchoice=805&option=1");
				use(1,$item[desert sightseeing pamphlet]);
			}
			if((gnasirProgress & 2) == 0 && have_item($item[can of black paint])) {
				visit_url("place.php?whichplace=desertbeach&action=db_gnasir");
				visit_url("choice.php?pwd&whichchoice=805&option=2");
				visit_url("choice.php?pwd&whichchoice=805&option=1");
				use(1,$item[desert sightseeing pamphlet]);
			}
			if((gnasirProgress & 4) == 0 && have_item($item[killing jar])) {
				visit_url("place.php?whichplace=desertbeach&action=db_gnasir");
				visit_url("choice.php?pwd&whichchoice=805&option=2");
				visit_url("choice.php?pwd&whichchoice=805&option=1");
				use(1,$item[desert sightseeing pamphlet]);
			}
			if((gnasirProgress & 8) == 0 && item_amount($item[worm-riding manual page])==15){
				visit_url("place.php?whichplace=desertbeach&action=db_gnasir");
				visit_url("choice.php?pwd&whichchoice=805&option=2");
				visit_url("choice.php?pwd&whichchoice=805&option=1");
				if(!have_item($item[worm-riding hooks])) abort("Trading for hook failed.");
				if(!have_item($item[drum machine]) && pulls_remaining()>0 && user_confirm("Do you want to pull drum machine?")) {
					take_storage(1,$item[drum machine]);
				} else {
					print_goal("Farming for drum machine..");
					obtain_item(1,$item[drum machine],$location[The Oasis]);
				}
				use(1,$item[drum machine]);
			}
		}
		get_backup_state();
	} else if (contains_text(visit_url("beach.php"),"pyramid.gif")) {
		print_quest_complete("You have already found the path to the pyramid.");
	} else {
		print_not_qualified("Desert path is not currently available.");
	}
}

void PyramidQuest()
{
	if (!contains_text(visit_url("beach.php"),"pyramid.gif")) {
		abort("The Small Pyramid is not currently available.");
	} else {
		visit_url("place.php?whichplace=desertbeach&action=db_pyramid1");
	}
	if (contains_text(visit_url("questlog.php?which=1"),"A Pyramid Scheme")) {

		if(!contains_text(visit_url("questlog.php?which=1"),"A Pyramid Scheme")) {
			if(!have_item($item[Staff of Ed])) {
				cli_execute("/paste Staff of Ed");
			}
			visit_url("place.php?whichplace=desertbeach&action=db_pyramid1");
		}
		
		print_goal("Opening path to middle chamber");
		open_location("place.php?whichplace=pyramid","pyramid_middle.gif",$location[The Upper Chamber]);
		
		// rat olfacting handled by WHAM
		if(!contains_text(visit_url("place.php?whichplace=pyramid"),"pyramid_bottom1a.gif")) {
			print_goal("Opening control room");
			open_location("place.php?whichplace=pyramid","pyramid_controlroom.gif",$location[The Middle Chamber]);
			print_goal("Get 10 wheel-turning device");
			if(item_amount($item[crumbling wooden wheel])+item_amount($item[tomb ratchet])<10) {
				obtain_item(10-item_amount($item[tomb ratchet]),$item[tomb ratchet],$location[The Middle Chamber]);
			}
			
			if(!have_item($item[ancient bomb])) {
				if(!have_item($item[ancient bronze token])) {
					while(!contains_text(visit_url("place.php?whichplace=pyramid&action=pyramid_control"),"pyramid_readout4.gif")) {
						if(!spinWheel()) abort("Problem during room switching..");
					}
					visit_url("place.php?whichplace=pyramid&action=pyramid_state4");
				}
				while(!contains_text(visit_url("place.php?whichplace=pyramid&action=pyramid_control"),"pyramid_readout3.gif")) {
					if(!spinWheel()) abort("Problem during room switching..");
				}
				visit_url("place.php?whichplace=pyramid&action=pyramid_state3");
			}		
			while(!contains_text(visit_url("place.php?whichplace=pyramid&action=pyramid_control"),"pyramid_readout1.gif")) {
				if(!spinWheel()) abort("Problem during room switching..");
			}
			visit_url("place.php?whichplace=pyramid&action=pyramid_state1");
		}
		
		if(contains_text(visit_url("place.php?whichplace=pyramid"),"pyramid_bottom1a.gif")) {
			if(my_adventures()<7) abort("Not enough adventures to confront Ed the Undying.");
			adventure(7,$location[The Lower Chambers]);
		} else {
			abort("Something wrong with the flow. Please recheck.");
		}
		
		council();
	} else if (contains_text(visit_url("questlog.php?which=2"),"A Pyramid Scheme")) {
		print_goal_complete("You have already completed A Pyramid Scheme.");
	} else {
		print_not_qualified("A Pyramid Scheme is not currently available.");
	}
}

void MacGuffinQuest()
{
   if (my_level() >= 11) {
        council();

		if (contains_text(visit_url("questlog.php?which=1"),"and the Quest for the Holy MacGuffin")) {
			DiaryQuest();
			LordSpookyravenQuest();
			WorshipQuest();
			PalindomeQuest();
			DesertQuest();
            PyramidQuest();
		} else if (contains_text(visit_url("questlog.php?which=2"),"and the Quest for the Holy MacGuffin")) {
			print_quest_complete("You have already completed the level 11 quest.");
		} else {
			print_warning("The level 11 quest is not currently available.");
		}
	} else {
		print_not_qualified("You must be at least level 11 to attempt this quest.");
	}
}

void main()
{
	MacGuffinQuest();
}
