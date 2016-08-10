import <QuestLib.ash>;
import <zlib.ash>;
import <Spookyraven.ash>;

void set_bathroom_choices() {
	// if the guy made of bees is alive, try to kill him
	if (get_property("guyMadeOfBeesDefeated").to_boolean() == false) {
		set_choices(105,3);
	} else {
		set_choices(105,2);
		set_choices(107,4);
	}
}

void set_bedroom_choices() {
	// One Nightstand (White): Fight an animated nightstand.
	set_choices(876,1);

	// One Nightstand (Mahogany): Get useless thing
	// Additionally you could check if you have Lord Spookyraven's spectacles equipped, and get your quest item if you don't already have it or the skill.
	set_choices(877,1);

	// One Nightstand (Ornate): Get Lord Spookyraven's spectacles, then the disposable camera.
	if (!have_item($item[Lord Spookyraven's spectacles]))
		set_choices(878,3);
	else
		set_choices(878,4);

	// One Nightstand (Wooden): Fight the remains of a jilted mistress if we already have the ballroom key.
	if(!have_item($item[antique hand mirror]))
		set_choices(879,3);
	else
		set_choices(879,1);
		
	// One Nightstand (Elegant): Get the gown.
	set_choices(880,1);
}

void SpookyravenUpstairs()
{
	UnlockSpookyraven();

	if(contains_text(visit_url("place.php?whichplace=manor2"),"manor2_ladys")) {
		visit_url("place.php?whichplace=manor2&action=manor2_ladys");
		set_bedroom_choices();
		cli_execute("conditions clear");
		if (!have_item($item[Lord Spookyraven's spectacles]))
		{
			print_goal("Searching for spectacles");
			obtain(1, $item[Lord Spookyraven's spectacles], $location[The Haunted Bedroom]);
			set_bedroom_choices();
		} else {
			print_goal_complete("Spectacles acquired.");
		}

		if(!have_item($item[Lady Spookyraven's finest gown])) {
			print_goal("Searching for gown");
			obtain(1, $item[Lady Spookyraven's finest gown], $location[The Haunted Bedroom]);
		} else {
			print_goal_complete("Gown acquired. Skipping Bedroom.");
		}
		
		if(!have_item($item[Lady Spookyraven's powder puff])) {
			print_goal("Searching for puff");
			obtain(1, $item[Lady Spookyraven's powder puff], $location[The Haunted Bathroom]);
		} else {
			print_goal_complete("Puff acquired. Skipping Bathroom.");
		}
		
		if(!have_item($item[Lady Spookyraven's dancing shoes])) {
			print_goal("Searching for shoes");
			obtain(1, $item[Lady Spookyraven's dancing shoes], $location[The Haunted Gallery]);
		} else {
			print_goal_complete("Shoes acquired. Skipping Gallery.");
		}
		
		print_goal("Bring items to ghost");
		visit_url("place.php?whichplace=manor2&action=manor2_ladys");
	} else {
		print_quest_complete("The second floor was cleared.");
	}
}

void GuyMadeOfBeeQuest() {
	int guyMadeOfBeesCount = get_property("guyMadeOfBeesCount").to_int();

	if (guyMadeOfBeesCount < 4 && 
		user_confirm("Would you like to prep the guy made of bees? You have said his name " + guyMadeOfBeesCount + " time(s)."))
	{
		if (!have_item($item[antique hand mirror]))	{
			print_goal("Searching for mirror");
			set_bedroom_choices();
			obtain(1, $item[antique hand mirror], $location[The Haunted Bedroom]);
		}

		if (guyMadeOfBeesCount < 4) {
			print_goal("Preparing the BeeGee for the upcoming quest.");
			while(guyMadeOfBeesCount<4) {
				while_abort();
				adventure(1, $location[The Haunted Bathroom]);
				guyMadeOfBeesCount = get_property("guyMadeOfBeesCount").to_int();
			}
		} else {
			print_goal_complete("You have already said the Guy Made of Bees' name " + guyMadeOfBeesCount + " times already, he's ready to be summoned.");
		}
	} else if (guyMadeOfBeesCount == 4) {
		print_quest_complete("You have prepared the Guy Made of Bees.");
	} else {
		print_not_qualified("You consciously ignore the BeeGee.");
	}
	
}

void main()
{
	SpookyravenUpstairs();
}
