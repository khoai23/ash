import <QuestLib.ash>;

int checkTwinPeakProgress() {
	int twinPeakProgress = to_int(get_property("twinPeakProgress"));
	if((twinPeakProgress & 1) == 0) {
		if(elemental_resistance($element[stench]) < 40.0) {
			if (have_familiar($familiar[Exotic Parrot])) {
				use_familiar($familiar[Exotic Parrot]);
			}
			if(have_skill($skill[elemental saucesphere])) {
				use_skill(1,$skill[elemental saucesphere]);
			}
			if(have_skill($skill[ghostly shell])) {
				use_skill(1,$skill[ghostly shell]);
			}
		}
		if(elemental_resistance($element[stench]) < 40.0) {
			abort("Ready for choice 1, but not enough resistance.");
		}
		set_choices(606,1);
		set_choices(607,1);
		return 1;
	} else if((twinPeakProgress & 2) == 0) {
		if((item_drop_modifier() < 50 && have_effect($effect[Brother Flying Burrito's Blessing])==0) || (item_drop_modifier() < 20)) {
			abort("Ready for choice 2, but not enough +item.");
		}
		set_choices(606,2);
		set_choices(608,1);
		return 2;
	} else if((twinPeakProgress & 4) == 0) {
		if(item_amount($item[Jar of Oil]) == 0) {
			if(!use(12,$item[bubblin' crude])) {	
				abort("Ready for choice 3, but not enough oil piece to make jar of oil.");
			}
		}
		set_choices(606,3);
		set_choices(609,1);
		set_choices(616,1);
		return 3;
	} else if(twinPeakProgress == 7) {
		if(initiative_modifier()<40) {
			if(item_amount($item[Lord Spookyraven's ear trumpet])>0) {
				equip($slot[acc3],$item[Lord Spookyraven's ear trumpet]);
			}
		}
		if(initiative_modifier()<40) {
			abort("Ready for choice 4, but not enough initiative.");
		}
		set_choices(606,4);
		set_choices(610,1);
		set_choices(617,1);
		return 4;
	} else if(twinPeakProgress>7){
		set_choices(606,0);
		return 5;
	} else {
		return 6;
	}
}

boolean bridgeComplete() {
	return get_property("chasmBridgeProgress").to_int() >= 30;
}
void buildBridge() {
	if(have_item($item[smut orc keepsake box])) {
		use(1,$item[smut orc keepsake box]);
	}
	visit_url("place.php?whichplace=orc_chasm&action=bridge"+get_property("chasmBridgeProgress"));
}

boolean oilPeakLit() {
	return contains_text(visit_url("place.php?whichplace=highlands"),"fire3.gif");
}

boolean ghostPeakReady() {
	return (to_int(get_property("booPeakProgress")) - item_amount($item[a-boo clue])*30)<=0;
}

void LOLQuest()
{
	if (my_level() >= 9)
	{
		council();

		if (contains_text(visit_url("questlog.php?which=1"),"There Can Be Only One Topping"))
		{
			if (!contains_text(visit_url("place.php?whichplace=orc_chasm"),"cross_chasm.gif"))
			{

				if ((available_amount($item[abridged dictionary]) == 0) && (available_amount($item[bridge]) == 0))
				{
					
					if(contains_text(visit_url("forestvillage.php"),"ut_cottage_quest.gif")) {
						vprint("Helping the untinker..","olive",5);
						visit_url("place.php?whichplace=forestvillage&action=fv_untinker_quest&preaction=screwquest");
					}
					if(contains_text(visit_url("questlog.php?which=1"),"Driven Crazy")) {
						vprint("Search for screwdriver","olive",5);
						obtain(1,$item[rusty screwdriver],$location[The Degrassi Knoll Garage]);
						visit_url("place.php?whichplace=forestvillage&action=fv_untinker");
					}
					
					if ((!have_outfit("swashbuckling getup") || !is_wearing_outfit("swashbuckling getup")))
					{	
						if(!user_confirm("Would you like to adventure for the swashbuckling getup?")) {
							abort("Nice attitude. Please keep your ass on your thumbs.");
						}
						vprint("Search for pirate outfit","olive",5);
						while(!have_outfit("swashbuckling getup"))
							adventure(1, $location[The Obligatory Pirate's Cove]);
					}
	
					cli_execute("checkpoint");
					if(item_amount($item[pirate fledges])>0 && can_equip($item[pirate fledges])) {
						equip($slot[acc3],$item[pirate fledges]);
					}
					else if (have_outfit("swashbuckling getup"))
					{
						outfit("swashbuckling getup");
					} 
					
					if(contains_text(visit_url("shop.php?whichshop=bartlebys"),"abridged")) {
						buy(1, $item[abridged dictionary]);
					} else {
						vprint("Dictionary already purchased.", "red",1);
					}
					
					cli_execute("outfit checkpoint");
				}
				
				if (available_amount($item[abridged dictionary]) > 0)
				{
					cli_execute("untinker abridged dictionary");
				}
				visit_url("place.php?whichplace=orc_chasm&action=label1");
				
				fulfill_condition("bridgeComplete","buildBridge",$location[The Smut Orc Logging Camp]);
				/*
				while(!bridgeComplete()) {
					while_abort();
					adventure(1,$location[The Smut Orc Logging Camp]);
					visit_url("place.php?whichplace=orc_chasm&action=bridge"+get_property("chasmBridgeProgress"));
					vprint("Trace progress: " + get_property("chasmBridgeProgress"),"olive",5);
				}
				*/
				
			} else {
				vprint("Bridge finished. Continuing to next part of the quest..","green",1);
			}
			
			visit_url("place.php?whichplace=highlands&action=highlands_dude");

			if (!oilPeakLit()) {
				vprint("Dealing with oil peak.","olive",5);
				fulfill_condition("oilPeakLit",$location[Oil Peak]);
				cli_execute("use 12 bubblin' crude");
			} else {
				vprint("Oil peak lighted.","green",1);
			}
			
			if (!contains_text(visit_url("place.php?whichplace=highlands"),"fire2.gif")) {
				vprint("Dealing with twin peak.","olive",5);
				cli_execute("checkpoint");
				set_choices(605,1);
				
				int choice = checkTwinPeakProgress();
				while(choice <=4) {
					choice = checkTwinPeakProgress();
					if(choice==6) {
						abort("Something went wrong in Twin Peak script.");
					}
					while_abort();
					adv1($location[Twin Peak],-1,"");
				}
				cli_execute("outfit checkpoint");
			} else {
				vprint("Twin peak lighted.","green",1);
			}
			
			if (!contains_text(visit_url("place.php?whichplace=highlands"),"fire1.gif")) {
				vprint("Dealing with ghost peak.","olive",5);
				
				int preparation = to_int(get_property("booPeakProgress")) - item_amount($item[a-boo clue])*30;
				if(preparation>0 && !user_confirm("Have you prepare yourselves to kill ghost?")) {
					abort("Please make your preparation and come again.");
				}
				
				fulfill_condition("ghostPeakReady",$location[A-Boo Peak]);
				/*
				while(preparation>0) {
					while_abort();
					adventure(1,$location[A-Boo Peak]);
					preparation = to_int(get_property("booPeakProgress")) - item_amount($item[a-boo clue])*30;
				}
				*/
				
				if(have_item($item[a-boo clue])) {
					vprint("Prepare for a-boo clues.","olive",5);
					if(!user_confirm("Are you ready for freezing and scary experiences?")) {
						abort("Please manually tune your outfit to withstand cold and spooky");
					}
					
					set_choices(611,1);
				}
				
				while(have_item($item[a-boo clue])) {
					while_abort();
					use(1,$item[a-boo clue]);
					adventure(1,$location[A-Boo Peak]);
				}
			} else {
				vprint("Ghost peak lighted.","green",1);
			}
			
			visit_url("place.php?whichplace=highlands&action=highlands_dude");
			
            council();
		}
		else if (contains_text(visit_url("questlog.php?which=2"),"There Can Be Only One Topping"))
		{
			vprint("You have already completed the level 9 quest.","green",1);
		}
		else
		{
			vprint("The level 9 quest is not currently available.","black",1);
		}
	}
	else
	{
		vprint("You must be at least level 9 to attempt this quest.","red",1);
	}
}

void main()
{
	LOLQuest();
}
