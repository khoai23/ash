import <QuestLib.ash>;
import <zlib.ash>;

record musician {
   item item1;
   item item2;
   boolean isdone;
};

musician [string] gollyMap;

gollyMap["Bognort"].item1 = $item[giant marshmallow]; 
gollyMap["Bognort"].item2 = $item[gin-soaked blotter paper]; 
gollyMap["Bognort"].isdone = false; 

gollyMap["Stinkface"].item1 = $item[gin-soaked blotter paper]; 
gollyMap["Stinkface"].item2 = $item[beer-scented teddy bear]; 
gollyMap["Stinkface"].isdone = false; 

gollyMap["Flargwurm"].item1 = $item[booze-soaked cherry]; 
gollyMap["Flargwurm"].item2 = $item[sponge cake]; 
gollyMap["Flargwurm"].isdone = false; 

gollyMap["Jim"].item1 = $item[sponge cake]; 
gollyMap["Jim"].item2 = $item[comfy pillow]; 
gollyMap["Jim"].isdone = false; 

void giveToGolly(item i, string who){
   print_debug("Giving " + i + " to " + who);
   if(item_amount(i) > 0 || take_closet(1, i)) {
      visit_url("pandamonium.php?action=sven&bandmember=" + who + "&togive=" + to_int(i) + "&preaction=try");
      gollyMap[who].isdone = true;
   }
}

boolean gollyDone() {
   int [item] trade;
   foreach it in $items[giant marshmallow,gin-soaked blotter paper,beer-scented teddy bear,booze-soaked cherry,sponge cake,comfy pillow]
      trade[it] = available_amount(it);
      
   boolean good = true;
   foreach name,mate in gollyMap{
      if(!mate.isdone) {
         if(trade[mate.item1] > 0) trade[mate.item1] -= 1;
         else if(trade[mate.item2] > 0) trade[mate.item2] -= 1;
         else good = false;
      }
   }
   return good;
}

void FriarsQuest()
{
    if (my_level() >= 6)
	{
        council();
	
		if (contains_text(visit_url("questlog.php?which=1"),"Trial By Friar"))
		{
			if (!have_item($item[Eldritch Butterknife])) {
				print_goal("Search for butterknife.");
				obtain(1, $item[Eldritch Butterknife], $location[The Dark Elbow of the Woods]);
			}
			if (!have_item($item[box of birthday candles]))	{
				print_goal("Search for box of birthday candles.");
				obtain(1, $item[box of birthday candles], $location[The Dark Heart of the Woods]);
			}
			if (!have_item($item[Dodecagram])) {
				print_goal("Search for dodecagram.");
				obtain(1, $item[Dodecagram], $location[The Dark Neck of the Woods]);
			}
			if (have_item($item[Eldritch Butterknife]) && have_item($item[box of birthday candles]) && have_item($item[Dodecagram])) {
				while_abort();
				adventure(1, $location[Friar Ceremony Location]);
			}
			
			council();
		}
		else if (contains_text(visit_url("questlog.php?which=2"),"Trial By Friar"))
		{
			print_quest_complete("You have already completed the level 6 quest.");
		}
		else
		{
			print_warning("The level 6 quest is not currently available.");
		}
	}
	else
	{
		print_not_qualified("You must be at least level 6 to attempt this quest.");
	}
}
void SteelQuest()
{
	if (my_level() >= 6)
	{
		visit_url("pandamonium.php");
		if (contains_text(visit_url("questlog.php?which=2"),"Trial By Friar"))
		{
			if (!contains_text(visit_url("questlog.php?which=2"),"this is Azazel in Hell.")) 
			{
				if (!have_item($item[Azazel's lollipop]))
				{
					if(!have_item($item[observational glasses])) {
						obtain(1, $item[observational glasses], $location[The Laugh Floor]);
					}
					
					while_abort();
					
					item original = equipped_item($slot[acc3]);					
					print_goal("Using observational humor...");
					equip($slot[acc3], $item[Observational glasses]);
					visit_url("pandamonium.php?action=mourn&preaction=observe");
					equip($slot[acc3], original);
				}
				
				if (!have_item($item[Azazel's unicorn]))
				{
					// Find out what bandmembers were previously completed
					string sven = visit_url("pandamonium.php?action=sven");
					// If this was the first visit to sven, he needs to be checked again
					if(sven.contains_text("value=\"help\""))
					sven = visit_url("pandamonium.php?action=sven");
					if(!sven.contains_text("You should probably go talk to the some of the band")) {
						foreach name in gollyMap
						if(!contains_text(sven, "<option>"+name))
							gollyMap[name].isdone = true;
					}
					
					fulfill_condition("gollyDone",$location[Infernal Rackets Backstage]);
					/*
					while (!gollyDone()) {
						while_abort();
						adventure(1,$location[Infernal Rackets Backstage]);
					}
					*/
					
					print_goal("Giving items to bandmembers...");
					foreach name, mate in gollyMap {
						if(!mate.isdone) {
							if(available_amount(mate.item1)>0)
								giveToGolly(mate.item1, name);
							else if(available_amount(mate.item2)>0)
								giveToGolly(mate.item2, name);
						}
					}
				}
				
				if (!have_item($item[Azazel's tutu]))
				{
					visit_url("pandamonium.php?action=moan");
					cli_execute("conditions clear");
					if(available_amount($item[imp air]) < 5) {
						obtain(5, $item[imp air], $location[The Laugh Floor]);
					}
					if(available_amount($item[bus pass]) < 5) {
						obtain(5, $item[bus pass], $location[Infernal Rackets Backstage]);
					}
					print_goal("Giving items to strangers...");
					visit_url("pandamonium.php?action=moan");
				}
				
				print_goal("Return Arazel's belonging...");
				visit_url("pandamonium.php?action=temp");

				if (available_amount($item[steel margarita]) > 0)
					overdrink(1, $item[steel margarita]);

				if (available_amount($item[steel lasagna]) > 0)
					eat(1, $item[steel lasagna]);

				if (available_amount($item[steel-scented air freshener]) > 0)
					use(1, $item[steel-scented air freshener]);
			}
			else
			{
				print_quest_complete("You have already completed the Azazel Quest.");
			}
		}
		else
		{
			print_not_qualified("You must first complete the level 6 quest to attempt this quest.");
		}
	}
	else
	{
		print_not_qualified("You must be at least level 6 to attempt this quest.");
	}
}

void main()
{
    FriarsQuest();
	SteelQuest();
}