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
		if (!have_item($item[Lord Spookyraven's spectacles]))
		{
			vprint("Searching for spectacles","olive",5);
			cli_execute("conditions clear");
			add_item_condition(1, $item[Lord Spookyraven's spectacles]);
			adventure(my_adventures(), $location[The Haunted Bedroom]);
			set_bedroom_choices();
		} else {
			vprint("Spectacles acquired.","green",1);
		}

		if(!have_item($item[Lady Spookyraven's finest gown])) {
			vprint("Searching for gown","olive",5);
			cli_execute("conditions clear");
			add_item_condition(1, $item[Lady Spookyraven's finest gown]);
			adventure(my_adventures(), $location[The Haunted Bedroom]);
		} else {
			vprint("Gown acquired. Skipping Bedroom.","green",1);
		}
		
		if(!have_item($item[Lady Spookyraven's powder puff])) {
			vprint("Searching for puff","olive",5);
			cli_execute("conditions clear");
			add_item_condition(1, $item[Lady Spookyraven's powder puff]);
			adventure(my_adventures(), $location[The Haunted Bathroom]);
		} else {
			vprint("Puff acquired. Skipping Bathroom.","green",1);
		}
		
		if(!have_item($item[Lady Spookyraven's dancing shoes])) {
			vprint("Searching for shoes","olive",5);
			cli_execute("conditions clear");
			add_item_condition(1, $item[Lady Spookyraven's dancing shoes]);
			adventure(my_adventures(), $location[The Haunted Gallery]);
		} else {
			vprint("Shoes acquired. Skipping Gallery.","green",1);
		}
		
		vprint("Bring items to ghost","olive",5);
		visit_url("place.php?whichplace=manor2&action=manor2_ladys");
	} else {
		vprint("The second floor was cleared.","green",1);
	}

	int guyMadeOfBeesCount = get_property("guyMadeOfBeesCount").to_int();

	if (guyMadeOfBeesCount < 4 && 
		user_confirm("Would you like to prep the guy made of bees? You have said his name " + guyMadeOfBeesCount + " time(s)."))
	{
		if (!have_item($item[antique hand mirror]))	{
			vprint("Searching for mirror","olive",5);
			set_bedroom_choices();
			cli_execute("conditions clear");
			add_item_condition(1, $item[antique hand mirror]);
			adventure(my_adventures(), $location[The Haunted Bedroom]);
		}

		if (guyMadeOfBeesCount < 4)
		{
			while(guyMadeOfBeesCount<4) {
				while_abort();
				adventure(1, $location[The Haunted Bathroom]);
				guyMadeOfBeesCount = get_property("guyMadeOfBeesCount").to_int();
			}
		} else {
			vprint("You have already said the Guy Made of Bees' name " + guyMadeOfBeesCount + " times already, he's ready to be summoned.","blue",1);
		}
	}
	else
	{
		if (guyMadeOfBeesCount == 4) {
			vprint("You have prepared the Guy Made of Bees.","green",1);
		} else {
			vprint("You don't care about the Guy Made of Bees.","black",1);
		}
	}
}

void main()
{
	SpookyravenUpstairs();
}
