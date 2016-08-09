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

string hiddenTempleAdventure() {
	// the function must be run AFTER having the Nostril
	string page = visit_url("adventure.php?snarfblat=280");
	
	if(contains_text(page,"Combat")) {
		page = run_combat();
		return page;
	} else if(contains_text(page,"Hidden Heart")) { // && have_item($item[The Nostril of The Serpent])
		// beginning opening the way to the hidden city
		// go to unconfusing button
		manual_run_choice(580,2);
		// go to pikachulotal
		manual_run_choice(584,4);
		// opening the way
		manual_run_choice(580,1);
		// choice raise hand
		manual_run_choice(123,2);
		page = visit_url("choice.php");
		// parsing the map and get your path
		int i = 0;
		int count = 0;
		string[63] mapping;
		while(i>=5) {
			i= index_of(page,"/tile",i);
			i+=5;
			mapping[count] = char_at(page,i);		
		}
		if(count!=63) abort("Parsing failed. Solve it yourself.");
		vprint("Parsing completed. Begin navigating..","blue",1);
		for row from 0 upto 6 {
			for column from 1 upto 9 {
				if(mapping[(6-row)*9+column-1]==answer[row]){
					vprint("Jump to tile " + column,"olive",5);
					visit_url("tiles.php?action=jump&whichtile=" + column);
					wait(1);
					break;
				}
			}
		}
		// do nothing to unlock
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
	if (available_amount($item[your father's MacGuffin diary]) == 0)
	{
		if (!blackMarketOpened())
		{
			cli_execute("conditions clear");
			set_choices(923,1);
			set_choices(1018,1);
			set_choices(1019,1);

			familiar family = my_familiar();
			if(have_familiar($familiar[Reassembled Blackbird])){
				use_familiar($familiar[Reassembled Blackbird]);
			}
			
			fulfill_condition("blackMarketOpened","helpWithBlackMarket",$location[The Black Forest]);
			/*
			while(!contains_text(visit_url("woods.php"),"blackmarket.gif")) {
				if (!have_familiar($familiar[Reassembled Blackbird]))
				{
					if(have_item($item[sunken eyes]) && have_item($item[broken wings])) {
						create(1,$item[reassembled blackbird]);
						use(1,$item[reassembled blackbird]);
						use_familiar($familiar[Reassembled Blackbird]);
					}
				}
				checkForestChoice();
				adventure(1,$location[The Black Forest]);
				while_abort();
			}
			*/
			
			use_familiar(family);
		} else {
			vprint("Path to Black Market already opened.","green",1);
		}

		if (contains_text(visit_url("shop.php?whichshop=blackmarket"),"forged identification documents"))
		{
			buy(1, $item[forged identification documents]);
		}

		if (available_amount($item[forged identification documents]) > 0)
		{
			if(!have_item($item[your father's MacGuffin diary]))
			{
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
				adv1($location[The Shore\, Inc. Travel Agency],-1,"");
			}
		}

		if (available_amount($item[your father's MacGuffin diary]) > 0)
		{
			visit_url("diary.php?textversion=1");
		}
		else
		{
			abort("Failed to retrieve your father's MacGuffin diary");
		}
	}
	else
	{
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
			vprint("Searching for the nostril of the serpent.","olive",5);
			obtain(1,$item[The Nostril of The Serpent],$location[The Hidden Temple]);
		} 
		
		custom_fight("hiddenCityOpened","hiddenTempleAdventure");
		
		/*boolean runTemple = false;
		while(!runTemple) {
			while_abort();
			restore_hp(0);
			restore_mp(0);
			runTemple = hiddenTempleAdventure();
		}*/
	} else {
		vprint("The path to the Hidden City are cleared.","green",1);
	}
}

void HiddenCityQuest()
{
	if(contains_text(visit_url("questlog.php?which=1"),"Gotta Worship Them All")) {
		if(!have_item($item[antique machete]) && !have_equipped($item[antique machete])) {
			if(pulls_remaining()==0 || !user_confirm("Do you wish to pull the machete instead?")) {
				vprint("Searching for machete","olive",5);
				set_choices(789,2);
				obtain(1,$item[antique machete],$location[The Hidden Park]);
			}
			else {
				take_storage(1,$item[antique machete]);
			}
		}
		
		item currentW = equipped_item($slot[weapon]);
		item currentH = equipped_item($slot[off-hand]);
		equip($slot[weapon],$item[antique machete]);
		if(!contains_text(visit_url("place.php?whichplace=hiddencity"),"The Hidden Apartment Building")){
			vprint("Unlocking Apartment..","blue",1);
			set_choices(781,1);
			while(get_property("lastEncounter") != "Earthbound and Down") {
				while_abort();
				adv1($location[An Overgrown Shrine (Northwest)],-1,"");
			}
		}
		if(!contains_text(visit_url("place.php?whichplace=hiddencity"),"The Hidden Office Building")){
			vprint("Unlocking Office..","blue",1);
			set_choices(785,1);
			while(get_property("lastEncounter") != "Air Apparent") {
				while_abort();
				adv1($location[An Overgrown Shrine (Northeast)],-1,"");
			}
		}
		if(!contains_text(visit_url("place.php?whichplace=hiddencity"),"The Hidden Hospital")){
			vprint("Unlocking Hospital..","blue",1);
			set_choices(783,1);
			while(get_property("lastEncounter") != "Water You Dune") {
				while_abort();
				adv1($location[An Overgrown Shrine (Southwest)],-1,"");
			}
		}
		if(!contains_text(visit_url("place.php?whichplace=hiddencity"),"The Hidden Bowling Alley")){
			vprint("Unlocking Bowling Alley..","blue",1);
			set_choices(787,1);
			while(get_property("lastEncounter") != "Fire When Ready") {
				while_abort();
				adv1($location[An Overgrown Shrine (Southeast)],-1,"");
			}
		}
		equip($slot[weapon],currentW);
		equip($slot[off-hand],currentH);
		
		if(!have_item($item[stone triangle])) {
			vprint("Searching for all spheres","blue",1);
			while(!have_item($item[moss-covered stone sphere])) {
				vprint("Searching for moss sphere","olive",5);
				if(have_effect($effect[Thrice-Cursed])>0) set_choices(780,1);
				else set_choices(780,3);
				while_abort();
				adventure(1,$location[The Hidden Apartment Building]);
			}
			
			while(!have_item($item[crackling stone sphere])) {
				vprint("Searching for crackling sphere","olive",5);
				// KolMafia automatically use the binder clips.
				if(have_item($item[McClusky file (complete)])) {
					set_choices(786,1);
				} 	else set_choices(786,2);
				while_abort();
				adventure(1,$location[The Hidden Office Building]);
			}
			
			if(!have_item($item[scorched stone sphere])) {
				vprint("Searching for scorched sphere","olive",5);
				set_choices(788,1);
				obtain(1,$item[scorched stone sphere],$location[The Hidden Bowling Alley]);
			}
			
			set_choices(784,1);
			if(!have_item($item[dripping stone sphere])) {
				vprint("Searching for dripping sphere","olive",5);
				cli_execute("checkpoint");
				if(!have_item($item[surgical apron]) && pulls_remaining()>0) {
					take_storage(1,$item[surgical apron]);
				}
				while(!have_item($item[dripping stone sphere])) {
					if(have_item($item[surgical apron])) equip($item[surgical apron]);
					if(have_item($item[bloodied surgical dungarees])) equip($item[bloodied surgical dungarees]);
					if(have_item($item[surgical mask])) equip($slot[acc3],$item[surgical mask]);
					if(have_item($item[head mirror])) equip($slot[acc2],$item[head mirror]);
					if(have_item($item[half-size scalpel])) equip($slot[weapon],$item[half-size scalpel]);
					while_abort();
					adventure(1,$location[The Hidden Hospital]);
				}
				cli_execute("outfit checkpoint");
			}
		}
		
		if(have_item($item[moss-covered stone sphere]) && have_item($item[crackling stone sphere])
		  && have_item($item[scorched stone sphere]) && have_item($item[dripping stone sphere])) {
			vprint("Trading spheres for triangles..","blue",1);
			adv1($location[An Overgrown Shrine (Northeast)],-1,"");
			adv1($location[An Overgrown Shrine (Southeast)],-1,"");
			adv1($location[An Overgrown Shrine (Northwest)],-1,"");
			adv1($location[An Overgrown Shrine (Southwest)],-1,"");
		} 
		
		if(item_amount($item[stone triangle])==4) {
			equip($slot[weapon],$item[antique machete]);
			set_choices(791,6);
			while(get_property("lastEncounter")!="Legend of the Temple in the Hidden City") {
				adv1($location[A Massive Ziggurat],-1,"");
				while_abort();
			}
			equip($slot[weapon],currentW);
			equip($slot[off-hand],currentH);
			set_choices(791,1);
			vprint("Taking down the Protector Spectre.","blue",1);
			adv1($location[A Massive Ziggurat],-1,"");
		} else abort("You(probably) have messed up the plan. Clean after yourself.");
		
	} else if(contains_text(visit_url("questlog.php?which=2"),"Gotta Worship Them All")) {
		vprint("You have already solve the Hidden City's mystery","green",1);
	} else {
		vprint("The Hidden City quest is unavailable.","black",1);
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
		cli_execute("conditions clear");
		set_choices(921,1);
        if (!cellarOpened())
		{
			vprint("Finding the hidden switch to the cellar","olive",5);
			fulfill_condition("cellarOpened",$location[The Haunted Ballroom]);
			/*
			while (!contains_text(visit_url("place.php?whichplace=manor1"), "sr_floor1_stairsdown.gif"))
			{
				while_abort();
                adventure(1, $location[The Haunted Ballroom]);
			}
			*/
		}
		
		visit_url("place.php?whichplace=manor4&action=manor4_chamberwall");
		if(have_item($item[recipe: mortar-dissolving solution]))
			vprint("Seeing the hidden bomb-making recipe","olive",5);
			if(have_item($item[Lord Spookyraven's spectacles])) {
				item subtitute = equipped_item($slot[acc3]);
				equip($slot[acc3],$item[Lord Spookyraven's spectacles]);
				use(1,$item[recipe: mortar-dissolving solution]);
				equip($slot[acc3],subtitute);
			} else {
				use(1,$item[recipe: mortar-dissolving solution]);
			}

		if (contains_text(visit_url("questlog.php?which=1"),"blasting soda"))
		{
			vprint("Find Vinegar bottle","olive",5);
			if(!have_item($item[bottle of Chateau de Vinegar])) {
				obtain(1,$item[bottle of Chateau de Vinegar],$location[The Haunted Wine Cellar]);
			}			
			
			vprint("Find blasting soda","olive",5);
			if(!have_item($item[blasting soda])) {
				obtain(1,$item[blasting soda],$location[The Haunted Laundry Room]);
			}
		} else if (!contains_text(visit_url("questlog.php?which=1"),"-or-") &&
			contains_text(visit_url("questlog.php?which=1"),"loosening powder")){
			abort("Screw YOUR scavenger hunt. Find that spectacles and try better thing.");
		}
		
		if (contains_text(visit_url("questlog.php?which=1"),"Cook up the explosive mixture")) {
			vprint("Cook the inert bomb","olive",5);
			create(1,$item[unstable fulminate]);
		}
		
		item currentW = equipped_item($slot[weapon]);
		item currentH = equipped_item($slot[off-hand]);
		if (contains_text(visit_url("questlog.php?which=1"),"Heat up the explosive mixture")) {
			vprint("Heat the bomb up","olive",5);
			if(have_equipped($item[unstable fulminate]) || equip($item[unstable fulminate])) {
				obtain(1,$item[wine bomb],$location[The Haunted Boiler Room]);
			} else {
				abort("Manually equip the unstable fulminate in hand and try again.");
			}
		}
		equip($slot[weapon],currentW);
		equip(currentH);
		
		if(have_item($item[wine bomb])) {
			vprint("Blow your way open!","olive",5);
			visit_url("place.php?whichplace=manor4&action=manor4_chamberwall");
		}
		
		if(contains_text(visit_url("questlog.php?which=1"),"confront Lord Spookyraven")) {
			vprint("Smash the lord of this spooky manor","olive",5);
			adventure(1,$location[Summoning Chamber]);
		}
	}
	else if (contains_text(visit_url("questlog.php?which=2"),"In a Manor of Spooking"))
	{
		vprint("You have already completed In a Manor of Spooking.","green",1);
	}
	else
	{
		vprint("In a Manor of Spooking is not currently available.","black",1);
	}
}

string takeDogPhoto() {
	string page = visit_url("adventure.php?snarfblat=386");
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
	if (contains_text(visit_url("questlog.php?which=1"),"Of Mice and Shen") || contains_text(visit_url("questlog.php?which=1"),"Never Odd Or Even"))
	{
		if (!have_item($item[Talisman o' Namsilat]) && (equipped_amount($item[Talisman o' Namsilat])==0))
		{
			cli_execute("checkpoint");
			PirateQuest();
			if (available_amount($item[pirate fledges]) > 0)
			{
				if(!equip($slot[acc3], $item[pirate fledges]))
					abort("Failed equipping fledge. Check your state.");

				vprint("Openning Belowdecks","olive",5);
				fulfill_condition("belowdecksOpened", $location[The Poop Deck]);
				/*
				while (!belowdecksOpened())
				{
					while_abort();
					adventure(1, $location[The Poop Deck]);
				}
				*/

				if (belowdecksOpened())
				{
					if (available_amount($item[snakehead charrrm]) < 2)
					{
						vprint("Searching for snakehead charrrm","olive",5);
						obtain(2-available_amount($item[snakehead charrrm]), $item[snakehead charrrm], $location[Belowdecks]);
					}
					// the item are made automatically by KolMafia.
				}
			}
			cli_execute("outfit checkpoint");
		}

		cli_execute("checkpoint");
		if (have_item($item[Talisman o' Namsilat]))
		{
			equip($slot[acc3], $item[Talisman o' Namsilat]);
		}
		if (contains_text(visit_url("plains.php"),"palinlink.gif"))
		{
			set_choices(129,1);
			if(!contains_text(visit_url("place.php?whichplace=palindome"),"Awkward")) {
				vprint("Opening path to Dr. Awkward","blue",1);
				custom_fight("haveVol1","takeDogPhoto");
				/*
				while(!have_item($item[I Love Me, Vol. I])) {
					while_abort();
					restore_hp(0);
					restore_mp(0);
					takeDogPhoto();
				}
				*/
				use(1,$item[I Love Me, Vol. I]);
			}
			if(!contains_text(visit_url("place.php?whichplace=palindome"),"Alarm")) {
				vprint("Opening path to Dr. Alarm","blue",1);
				custom_fight("haveAllPhoto","takeDogPhoto");
				/*while(!have_item($item[photograph of a dog]) || !have_item($item[photograph of God]) 
				  || !have_item($item[photograph of a red nugget]) || !have_item($item[photograph of an ostrich egg])) {
					while_abort();
					restore_hp(0);
					restore_mp(0);
					takeDogPhoto();
				}*/
				
				if(!have_item($item[2 Love Me, Vol. 2])) {
					visit_url("place.php?whichplace=palindome&action=pal_droffice");
					visit_url("choice.php?pwd&whichchoice=872&option=1&photo1=2259&photo2=7264&photo3=7263&photo4=7265");
					if(have_item($item[Clan VIP Lounge key]) && user_confirm("Use the hottub to recuperate?"))
						visit_url("clan_viplounge.php?action=hottub");
					else if(user_confirm("Rest at campsite?")) 
						visit_url("campground.php?action=rest");
					else 
						abort("Please heal up and continue.");
				}
				use(1,$item[2 Love Me, Vol. 2]);
			}
			visit_url("place.php?whichplace=palindome&action=pal_mroffice");
			
			set_choices(131,1);
			if(contains_text(visit_url("questlog.php?which=1"),"wet stunt nut stew")) {
				vprint("Searching for wet stunt nut stew","blue",1);
				obtain(1, $item[wet stunt nut stew], $location[Inside the Palindome]);
				visit_url("place.php?whichplace=palindome&action=pal_mroffice");
			}
			
			if(have_item($item[Mega Gem])) {
				vprint("Avenging yourself!","blue",1);
				equip($slot[acc2],$item[Mega Gem]);
				string page = visit_url("place.php?whichplace=palindome&action=pal_droffice");
				page=run_choice(page);
				page=run_combat();
			}
		}
		cli_execute("outfit checkpoint");
	}
	else if (contains_text(visit_url("questlog.php?which=2"),"Never Odd Or Even"))
	{
		vprint("You have already completed Never Odd Or Even.","green",1);
	}
	else
	{
		vprint("Never Odd Or Even is not currently available.","black",1);
	}
}

void DesertQuest()
{
    if (contains_text(visit_url("questlog.php?which=1"),"Just Deserts"))
	{
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
					adv1($location[The Shore\, Inc. Travel Agency],-1,"");
				}
				//buy(1,$item[UV-resistant compass]);
				cli_execute("/buy UV-resistant compass");
			}
		}
		
		cli_execute("checkpoint");
		if(have_item($item[UV-resistant compass])) equip($item[UV-resistant compass]);
		
		if(!contains_text(visit_url("beach.php"),"oasis.gif")) {
			while_abort();
			adventure(1, $location[The Arid\, Extra-Dry Desert]);
		}

		if(!contains_text(visit_url("beach.php"),"gnasir.gif"))
		{
			set_choices(805,1);
			while_abort();
			adventure(have_effect($effect[Ultrahydrated]), $location[The Arid\, Extra-Dry Desert]);
		}
		
		// searching for stone rose
		if((get_property("gnasirProgress").to_int() & 1) == 0 && !have_item($item[stone rose])) {
			obtain(1,$item[stone rose],$location[The Oasis]);
		}
		
		// acquiring can of black paint
		if((get_property("gnasirProgress").to_int() & 2) == 0 && !have_item($item[can of black paint])) {			
			buy(1,$item[can of black paint]);
		}

		int gnasirProgress = get_property("gnasirProgress").to_int();
		while(get_property("desertExploration").to_int()<100) {
			while_abort();
			if(have_effect($effect[Ultrahydrated])==0) adventure(1,$location[The Oasis]);
			else adventure(1,$location[The Arid\, Extra-Dry Desert]);
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
				if(!have_item($item[drum machine]) && pulls_remaining()>0) {
					if(user_confirm("Do you want to pull drum machine?")) {
						take_storage(1,$item[drum machine]);
					} else {
						vprint("Farming for drum machine..","olive",5);
						cli_execute("conditions clear");
						add_item_condition(1,$item[drum machine]);
						adventure(my_adventures(),$location[The Oasis]);
					}
				}
				use(1,$item[drum machine]);
			}
		}
		cli_execute("outfit checkpoint");
	}
	else if (contains_text(visit_url("beach.php"),"pyramid.gif"))
	{
		vprint("You have already found the path to the pyramid.","green",1);
	}
	else
	{
		vprint("Desert path is not currently available.","black",1);
	}
}

void PyramidQuest()
{
	if (contains_text(visit_url("questlog.php?which=1"),"A Pyramid Scheme"))
	{
		if (!contains_text(visit_url("beach.php"),"pyramid.gif")) {
			abort("The Small Pyramid is not currently available.");
		}

		if(!contains_text(visit_url("questlog.php?which=1"),"A Pyramid Scheme")) {
			if(!have_item($item[Staff of Ed])) {
				cli_execute("/paste Staff of Ed");
			}

			visit_url("place.php?whichplace=desertbeach&action=db_pyramid1");
		}
		
		vprint("Opening path to middle chamber","olive",5);
		open_location("place.php?whichplace=pyramid","pyramid_middle.gif",$location[The Upper Chamber]);
		/*while(!contains_text(visit_url("place.php?whichplace=pyramid"),"pyramid_middle.gif")) {
			while_abort();
			adventure(1,$location[The Upper Chamber]);
		}*/
		
		// rat olfacting handled by WHAM
		if(!contains_text(visit_url("place.php?whichplace=pyramid"),"pyramid_bottom1a.gif")) {
			vprint("Opening control room","olive",5);
			open_location("place.php?whichplace=pyramid","pyramid_controlroom.gif",$location[The Middle Chamber]);
			/*while(!contains_text(visit_url("place.php?whichplace=pyramid"),"pyramid_controlroom.gif")) {
				while_abort();
				adventure(1,$location[The Middle Chamber]);
			}*/
			vprint("Get 10 wheel-turning device","olive",5);
			if(item_amount($item[crumbling wooden wheel])+item_amount($item[tomb ratchet])<10) {
				obtain(10-item_amount($item[crumbling wooden wheel])-item_amount($item[tomb ratchet]),$item[tomb ratchet],$location[The Middle Chamber]);
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
	}
	else if (contains_text(visit_url("questlog.php?which=2"),"A Pyramid Scheme"))
	{
		vprint("You have already completed A Pyramid Scheme.","green",1);
	}
	else
	{
		vprint("A Pyramid Scheme is not currently available.","black",1);
	}
}

void MacGuffinQuest()
{
    if (my_level() >= 11)
	{
        council();

		if (contains_text(visit_url("questlog.php?which=1"),"and the Quest for the Holy MacGuffin"))
		{
			DiaryQuest();
			LordSpookyravenQuest();
			WorshipQuest();
			PalindomeQuest();
			DesertQuest();
            PyramidQuest();
		}
		else if (contains_text(visit_url("questlog.php?which=2"),"and the Quest for the Holy MacGuffin"))
		{
			vprint("You have already completed the level 11 quest.","green",1);
		}
		else
		{
			vprint("The level 11 quest is not currently available.","red",1);
		}
	}
	else
	{
		vprint("You must be at least level 11 to attempt this quest.","black",1);
	}
}

void main()
{
	MacGuffinQuest();
}
