import <QuestLib.ash>;

record musician {
   item item1;
   item item2;
   boolean isdone;
};

musician [string] gollyMap;

gollyMap["Bognort"].item1 = $item[giant marshmallow]; 
gollyMap["Bognort"].item2 = $item[gin-soaked blotter paper]; 
gollyMap["Bognort"].isdone = false; 

gollyMap["Stinkface"].item1 = $item[beer-scented teddy bear]; 
gollyMap["Stinkface"].item2 = $item[gin-soaked blotter paper]; 
gollyMap["Stinkface"].isdone = false; 

gollyMap["Flargwurm"].item1 = $item[booze-soaked cherry]; 
gollyMap["Flargwurm"].item2 = $item[sponge cake]; 
gollyMap["Flargwurm"].isdone = false; 

gollyMap["Jim"].item1 = $item[comfy pillow]; 
gollyMap["Jim"].item2 = $item[sponge cake]; 
gollyMap["Jim"].isdone = false; 

void giveToGolly(item i, string who){
   print_debug("Giving " + i + " to " + who);
   if(have_item(i)) {
      visit_url("pandamonium.php?action=sven&bandmember=" + who + "&togive=" + to_int(i) + "&preaction=try");
      gollyMap[who].isdone = true;
   }
}

boolean gollyDone() {
   boolean [item] trade;
   foreach it in $items[giant marshmallow,gin-soaked blotter paper,beer-scented teddy bear,booze-soaked cherry,sponge cake,comfy pillow]
      trade[it] = have_item(it);
      
   boolean good = true;
   foreach name,mate in gollyMap{
      if(!mate.isdone) {
         if(trade[mate.item1]) trade[mate.item1] = false;
         else if(trade[mate.item2]) trade[mate.item2] = false;
         else good = false;
      }
   }
   return good;
}

void FriarsQuest()
{
    if (my_level() >= 6) {
        council();
	
		if (contains_text(visit_url("questlog.php?which=1"),"Trial By Friar")) {
			if (!have_item($item[Eldritch Butterknife])) {
				print_goal("Search for butterknife.");
				obtain_item(1, $item[Eldritch Butterknife], $location[The Dark Elbow of the Woods]);
			} else {
				print_goal_complete("Already have butterknife.");
			}
			if (!have_item($item[box of birthday candles]))	{
				print_goal("Search for box of birthday candles.");
				obtain_item(1, $item[box of birthday candles], $location[The Dark Heart of the Woods]);
			} else {
				print_goal_complete("Already have box of birthday candles.");
			}
			if (!have_item($item[Dodecagram])) {
				print_goal("Search for dodecagram.");
				obtain_item(1, $item[Dodecagram], $location[The Dark Neck of the Woods]);
			} else {
				print_goal_complete("Already have dodecagram.");
			}
			if (have_item($item[Eldritch Butterknife]) && have_item($item[box of birthday candles]) && have_item($item[Dodecagram])) {
				while_abort();
				adventure(1, $location[Friar Ceremony Location]);
			}
			
			council();
		} else if (contains_text(visit_url("questlog.php?which=2"),"Trial By Friar")) {
			print_quest_complete("You have already completed the level 6 quest.");
		} else {
			print_warning("The level 6 quest is not currently available.");
		}
	} else {
		print_not_qualified("You must be at least level 6 to attempt this quest.");
	}
}
void SteelQuest()
{
	if (my_level() >= 6) {
	
		visit_url("pandamonium.php");
		if (contains_text(visit_url("questlog.php?which=2"),"Trial By Friar")) {
			if (!contains_text(visit_url("questlog.php?which=2"),"this is Azazel in Hell.")) {
				
				set_backup_state();
				maximize_item();
			
				if (!have_item($item[Azazel's lollipop])) {
					if(!have_item($item[observational glasses])) {
						print_goal("Searching for appropriate tools.");
						obtain_item(1, $item[observational glasses], $location[The Laugh Floor]);
					} else {
						print_goal_complete("Already have all the tools.");
					}
					
					while_abort();
					
					cli_execute("checkpoint");
					print_goal("Using tools.");
					equip($slot[acc3], $item[Observational glasses]);
					equip($slot[weapon],$item[hilarious comedy prop]);
					equip($item[Victor\, the Insult Comic Hellhound Puppet]);
					visit_url("pandamonium.php?action=mourn&preaction=observe");
					visit_url("pandamonium.php?action=mourn&preaction=prop");
					visit_url("pandamonium.php?action=mourn&preaction=insult");
					cli_execute("outfit checkpoint");
				}
				
				if (!have_item($item[Azazel's unicorn])) {
					// Meeting sven
					string sven = visit_url("pandamonium.php?action=sven");
					// If this is the first visit to sven, he needs to be checked again
					if(sven.contains_text("value=\"help\""))
					sven = visit_url("pandamonium.php?action=sven");
					if(!sven.contains_text("You should probably go talk to the some of the band")) {
						foreach name in gollyMap
						if(!contains_text(sven, "<option>"+name))
							gollyMap[name].isdone = true;
					}
					
					fulfill_condition("gollyDone",$location[Infernal Rackets Backstage]);
					
					print_goal("Giving items to bandmembers.");
					foreach name, mate in gollyMap {
						if(!mate.isdone) {
							if(available_amount(mate.item1)>0)
								giveToGolly(mate.item1, name);
							else if(available_amount(mate.item2)>0)
								giveToGolly(mate.item2, name);
						}
					}
				}
				
				if (!have_item($item[Azazel's tutu])) {
					visit_url("pandamonium.php?action=moan");
					cli_execute("conditions clear");
					print_goal("Searching for items.");
					if(available_amount($item[imp air]) < 5) {
						obtain_item(5, $item[imp air], $location[The Laugh Floor]);
					}
					if(available_amount($item[bus pass]) < 5) {
						obtain_item(5, $item[bus pass], $location[Infernal Rackets Backstage]);
					}
					print_goal("Giving items to strangers.");
					visit_url("pandamonium.php?action=moan");
				}
				
				print_goal("Return Arazel's belonging.");
				visit_url("pandamonium.php?action=temp");

				if (have_item($item[steel margarita]))
					overdrink(1, $item[steel margarita]);

				if (have_item($item[steel lasagna]))
					eat(1, $item[steel lasagna]);

				if (have_item($item[steel-scented air freshener]))
					use(1, $item[steel-scented air freshener]);
				get_backup_state();
			} else {
				print_quest_complete("You have already completed the Azazel Quest.");
			}
		} else {
			print_not_qualified("You must first complete the level 6 quest to attempt this quest.");
		}
	} else {
		print_not_qualified("You must be at least level 6 to attempt this quest.");
	}
}

void main()
{
    FriarsQuest();
	if(user_confirm("Do Arazel's quest?"))
		SteelQuest();
}