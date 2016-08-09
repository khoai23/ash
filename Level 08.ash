import <QuestLib.ash>;
import <zlib.ash>;

int maxprice = 1000;
boolean slope_complete = false;

string noncom_slope_complete(int round, string opp, string text) {
	if(text.contains_text("Perfect Melancholy")) {
		slope_complete = true;
	}
	return get_ccs_action(round);
}

void TrapperQuest()
{
    if (my_level() >= 8)
	{
        council();

		if (contains_text(visit_url("questlog.php?which=1"),"Am I My Trapper's Keeper"))
		{
			visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
	
			if (contains_text(visit_url("questlog.php?which=1"),"wedges of goat cheese"))
			{
				print("First part of quest begin.","green");
				item ore = $item[linoleum ore];
				string ore_type = "";
				
				if (contains_text(visit_url("place.php?whichplace=mclargehuge&action=trappercabin"), "chrome ore"))
				{
					ore = $item[chrome ore];
					ore_type = " chrome ore";
				}
				else if (contains_text(visit_url("place.php?whichplace=mclargehuge&action=trappercabin"), "asbestos ore"))
				{
					ore = $item[asbestos ore];
					ore_type = " asbestos ore";
				}
				else if (contains_text(visit_url("place.php?whichplace=mclargehuge&action=trappercabin"), "linoleum ore"))
				{
					ore = $item[linoleum ore];
					ore_type = " linoleum ore";
				}
				else 
				{
					abort("Cannot find ore");
				}
				
				if(item_amount(ore) < 3) {
					if(pulls_remaining()>=3 && user_confirm("Would you like to pull"+ore_type+"?")) {
						// pull ore, will purchase if not enough
						if((storage_amount(ore) + item_amount(ore)) < 3) {
							if(buy_using_storage(3-(storage_amount(ore) + item_amount(ore)), ore, maxprice) < 3) 
								abort("Cannot autobuy ore, please manually purchase from the mall");
						}
						cli_execute("pull " + (3-item_amount(ore) + ore_type));
					} else {
						vprint("Farming for miner outfit.","olive",5);
						// adventure for outfit & mining
						while(!have_outfit("mining gear")) {
							adventure(1,$location[Itznotyerzitz Mine]);
							while_abort();
						}
						vprint("Outfit farmed","olive",5);
						abort("Mine it yourself. Fag.");
					}
				} else {
					vprint("Have enough ore.","green",1);
				}
				
				if(item_amount($item[goat cheese]) < 3) {
					vprint("Farming for cheese.","olive",5);
					cli_execute("conditions clear");
					add_item_condition(3-item_amount($item[goat cheese]), $item[goat cheese]);
					adventure(my_adventures(),$location[The Goatlet]);
				} else {
					vprint("Have enough cheese.","green",1);
				}
	
				visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
			} else {
				vprint("First part of the quest completed.","green",1);
			}
	
			if (contains_text(visit_url("questlog.php?which=1"),"investigate the top"))
			{
				boolean have_outfit = false;
				cli_execute("checkpoint");
				familiar current_familiar = my_familiar();
				vprint("Second part of the quest begin.","olive",1);
				
				if(elemental_resistance($element[cold]) >= 48.3 && have_familiar($familiar[Jumpsuited Hound Dog])) {
					// 5 resist =  48.3%
					// if have enough resistance+JHD familiar, go ninja route
					if(item_amount($item[ninja carabiner])>0 && item_amount($item[ninja crampons])>0 && item_amount($item[ninja rope])>0) {
						vprint("Already have ninja climbing set.","blue",1);
					} else if(pulls_remaining() >= 3 && user_confirm("Pulling ninja climbing set?")) {
						cli_execute("pull ninja carabiner");
						cli_execute("pull ninja crampons");
						cli_execute("pull ninja rope");
					} else {
						use_familiar($familiar[Jumpsuited Hound Dog]);
						vprint("Searching for ninja gear","olive",5);
						while(item_amount($item[ninja carabiner])==0 || item_amount($item[ninja crampons])==0 || item_amount($item[ninja rope])==0) {
							while_abort();
							adventure(1,$location[Lair of the Ninja Snowmen]);
						}
						use_familiar(current_familiar);
					}
				} else {
					// default skiing - searching for outfit
					vprint("Searching for cold weather gear","olive",5);
					while(!have_outfit("eXtreme Cold-Weather Gear") && !is_wearing_outfit("eXtreme Cold-Weather Gear")) {
						adventure(1,$location[The eXtreme Slope]);
						while_abort();
					}
					
					// commence skiing
					vprint("Skiing on slope","olive",5);
					cli_execute("checkpoint");
					if(have_outfit("eXtreme Cold-Weather Gear")) {
						outfit("eXtreme Cold-Weather Gear");
					}
					while(!slope_complete) {
						adventure(1,$location[The eXtreme Slope],"noncom_slope_complete");
						while_abort();
						if(get_property("lastEncounter") == "3 eXXXtreme 4ever 6pack") slope_complete=true; 
					}
				}

				vprint("Climb the hard way.","olive",5);
				visit_url("place.php?whichplace=mclargehuge&action=cloudypeak");
	
			    use_familiar(current_familiar);
			    cli_execute("outfit checkpoint");
			} else {
				vprint("Second part of the quest completed.","green",1);
			}
			
			if (contains_text(visit_url("questlog.php?which=1"),"Icy Peak")) {
				// add script to increase cold resistance
				if(elemental_resistance($element[cold]) < 48.3) {
					if(have_outfit("eXtreme Cold-Weather Gear")) {
						outfit("eXtreme Cold-Weather Gear");
					} else {
						abort("Please tailor your outfit to give 5 CR and retain combat capability");
					}
				} else {
					vprint("You have sufficient cold protection. Go and get these yeti rolling!","blue",2);
				}
				//print("Find and kill Groar..","blue");
				
				vprint("Kill first yeti:","olive",5);
				visit_url("place.php?whichplace=mclargehuge&action=cloudypeak2");
				run_combat();
				vprint("Kill second yeti:","olive",5);
				visit_url("place.php?whichplace=mclargehuge&action=cloudypeak2");
				run_combat();
				vprint("Kill third yeti:","olive",5);
				visit_url("place.php?whichplace=mclargehuge&action=cloudypeak2");
				run_combat();
				vprint("Kill Groar:","olive",5);
				visit_url("place.php?whichplace=mclargehuge&action=cloudypeak2");
				run_combat();
				
				cli_execute("outfit checkpoint");
			}
	
			vprint("Finish quest","olive",5);
			visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
	
			council();
		}
		else if (contains_text(visit_url("questlog.php?which=2"),"Am I My Trapper's Keeper?"))
		{
			vprint("You have already completed the level 8 quest.","green",1);
		}
		else
		{
			vprint("The level 8 quest is not currently available.","black",1);
		}
	}
	else
	{
		vprint("You must be at least level 8 to attempt this quest.","red",1);
	}
}

void main()
{
	TrapperQuest();
}