import <QuestLib.ash>;

boolean haveLibraryKey() {
	return have_item($item[Spookyraven library key]);
}

void raiseBillardChance() {
	if (have_item($item[pool cue]))	{
		if(my_primestat() == $stat[muscle]) {
			equip($item[pool cue]);
		}
	}

	if (have_effect($effect[Chalky Hand]) == 0)	{
		if (have_item($item[handful of hand chalk])) {
			use(1, $item[handful of hand chalk]);
		}
	}
} 

void UnlockSpookyraven()
{
	if (!contains_text(visit_url("place.php?whichplace=manor1"),"action=manor1lock_stairsup"))
	{
		print_quest_complete("The second floor of Spookyraven is already unlocked.");
		return;
	}
	
	if(!have_item($item[Spookyraven billiards room key])) {
		print_goal("Searching for billiards key.");
		obtain_item(1, $item[Spookyraven billiards room key], $location[The Haunted Kitchen]);
	}

	if (!haveLibraryKey())	{
		if(!user_confirm("Can you kill ghost?")) {
			abort("Return later, when you are able");
		}
		set_choices(875,1);
		if(my_inebriety()<10 && user_confirm("Do you wish to drink to 10 and maximize your chance at billard?")) {
			abort("Go ahead.");
		} 
		
		cli_execute("conditions clear");
		cli_execute("checkpoint");
		fulfill_condition("haveLibraryKey","raiseBillardChance", $location[The Haunted Billiards Room]);
		cli_execute("outfit checkpoint");
	}

	if(!have_item($item[Lady Spookyraven's necklace])) {
		print_goal("Searching for necklace.");
		obtain_item(1,$item[Lady Spookyraven's necklace],$location[The Haunted Library]);
	}
	
	print_goal("Giving the ghost her necklace");
	visit_url("place.php?whichplace=manor1&action=manor1_ladys");
}

void main()
{
	UnlockSpookyraven();
}
