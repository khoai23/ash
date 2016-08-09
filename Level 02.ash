import <QuestLib.ash>;
import <zlib.ash>;

boolean larva = false;
boolean templeMap = true;

string searchWood(boolean target) {
	buffer page = visit_url("adventure.php?snarfblat=15");
	
	if(contains_text(page,"Combat")) {
		run_combat();
	} else if(contains_text(page,"Arboreal Respite")){
		// only 1 noncombat exist
		if(target == larva) {
			visit_url("choice.php?pwd&whichchoice=502&option=2");
			visit_url("choice.php?pwd&whichchoice=505&option=1");
		} else {
			if(!have_item($item[spooky temple map])) {
				if(have_item($item[tree-holed coin])) {
					visit_url("choice.php?pwd&whichchoice=502&option=3");
					visit_url("choice.php?pwd&whichchoice=506&option=3");	
					visit_url("choice.php?pwd&whichchoice=507&option=1");	
				} else {
					visit_url("choice.php?pwd&whichchoice=502&option=2");
					visit_url("choice.php?pwd&whichchoice=505&option=2");
				}
			} else if(!have_item($item[Spooky-Gro fertilizer])) {
				visit_url("choice.php?pwd&whichchoice=502&option=3");
				visit_url("choice.php?pwd&whichchoice=506&option=2");
			} else if(!have_item($item[spooky sapling])) {
				visit_url("choice.php?pwd&whichchoice=502&option=1");
				visit_url("choice.php?pwd&whichchoice=503&option=3");
				visit_url("choice.php?pwd&whichchoice=504&option=3");
				visit_url("choice.php?pwd&whichchoice=504&option=4");
			} else {
				abort("You somehow already had all the component for the map.");
			}
		}
	}
	
	return page;
}

boolean haveLarva() {
	return have_item($item[mosquito larva]);
}

void MosquitoQuest()
{
    if (my_level() >= 2)
	{
        council();

		if (contains_text(visit_url("questlog.php?which=1"),"Looking for a Larva in All the Wrong Places"))
		{
			if (!haveLarva())
			{
				print_goal("Using custom duty searcher to find larva");
				custom_fight("haveLarva","searchWood",larva);
				/*while(!have_item($item[mosquito larva]) {
					restore_hp(0);
					restore_mp(0);
					while_abort();
					searchWood(larva);
				}*/
			}
			else
			{
				print_quest_complete("You've already acquires a mosquito larva.");
			}
			
			council();
		}
		else if (contains_text(visit_url("questlog.php?which=2"),"Looking for a Larva in All the Wrong Places"))
		{
			print_quest_complete("You have already completed the level 2 quest.");
		}
		else
		{
			print_warning("The level 2 quest is not currently available.");
		}
	}
	else
	{
		print_not_qualified("You must be at least level 2 to attempt this quest.");
	}
}

boolean reachHiddenTemple() {
	if(have_item($item[spooky temple map]) && have_item($item[Spooky-Gro fertilizer]) && have_item($item[spooky sapling])) {
		use(1,$item[spooky temple map]);
		return true;
	}
	return contains_text(visit_url("woods.php"),"temple.gif");
}

void OpenTemple() {
	if(!reachHiddenTemple()) {
		print_goal("Searching for map and associating items..");
		
		custom_fight("reachHiddenTemple","searchWood",templeMap);
		/*while(!have_item($item[spooky temple map]) || !have_item($item[Spooky-Gro fertilizer]) || !have_item($item[spooky sapling])) {
			restore_hp(0);
			restore_mp(0);
			while_abort();
			searchWood(templeMap);
		}*/
	} else {
		print_quest_complete("The path to the Hidden Temple is already openned.");
	}
}

void main()
{
	MosquitoQuest();
	OpenTemple();
}