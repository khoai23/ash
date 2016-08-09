import <QuestLib.ash>;
import <zlib.ash>;

void sonarUse() {
	if(have_item($item[sonar-in-a-biscuit]))
		use(item_amount($item[sonar-in-a-biscuit]),$item[sonar-in-a-biscuit]);
}

void BatQuest()
{  
	if (my_level() >= 4) 
	{
		council();
	
		if (contains_text(visit_url("questlog.php?which=1"),"Ooh, I Think I Smell a Bat.")) {
			// Try opening the way to the lair
			if(elemental_resistance($element[stench]) >= 10.00) {
				print_debug("Have enough resistance(1).");
			} else if(user_confirm("Do you wish to find stench resistance in the entryway instead?")) {
				obtain(1,$item[Pine-Fresh air freshener], $location[The Bat Hole Entrance]);
			} else {
				abort("Please boost stench resistance and try again.");
			}
			
			if(elemental_resistance($element[stench]) >= 10.00) {
				print_goal("Finding the way to the boss room");
				open_location("bathole.php","bathole_4.gif",$location[Guano Junction]);
				print_debug("Opened way to the boss room");
			}
			
			// killing Boss Bat and its retinue
            if (contains_text(visit_url("bathole.php"),"The Boss Bat's Lair (1)")) {
				if (user_confirm("Try for the Boss Bat britches?"))
				{
					change_mcd(4);
				}
				else if (user_confirm("Try for the Boss Bat bling?"))
				{
					change_mcd(8);
				}
				else if ((canadia_available()) && (!contains_text(visit_url("trophies.php"),"Boss Boss")))
				{
					if (user_confirm("Try for the Boss Boss trophy?"))
					{
						change_mcd(11);      
					}
				}

				while (contains_text(visit_url("bathole.php"),"The Boss Bat's Lair (1)"))
				{
					while_abort();
					adventure(1, $location[The Boss Bat's Lair]);
				}
			}
			else
			{
				print_quest_complete("The Boss Bat had been vanquished. You diligent person you.");
			}
			
			council();
		}
		else if (contains_text(visit_url("questlog.php?which=2"),"Ooh, I Think I Smell a Bat."))
		{
			print_quest_complete("You have already completed the level 4 quest.");
		}
		else
		{
			print_warning("The level 4 quest is not currently available.");
		}
	}
	else
	{
		print_not_qualified("You must be at least level 4 to attempt this quest.");
	}
}

void main()
{
	BatQuest();
}
