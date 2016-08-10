script "junkship.ash";
import <QuestLib.ash>;

void setAdventure() {
	if(!have_item($item[old claw-foot bathtub])) set_choices(794,1);
	else if(!have_item($item[old clothesline pole])) set_choices(794,2);
	else set_choices(794,3);
}

boolean haveComponent() {
	return have_item($item[old claw-foot bathtub]) && have_item($item[old clothesline pole]) && have_item($item[antique cigar sign]);
}
void main() {	
	if(contains_text(visit_url("woods.php"),"smokesignals.gif")) {
		print_goal("Talking to the stranded hippy..");
		visit_url("place.php?whichplace=woods&action=woods_smokesignals");
		visit_url("choice.php?pwd&whichchoice=798&option=1");
		visit_url("choice.php?pwd&whichchoice=798&option=2");
	}
	if(contains_text(visit_url("questlog.php?which=1"),"Give a Hippy a Boat")) {
		
		set_choices(795,1);
		set_choices(796,2);
		set_choices(797,3);
		setAdventure();
		fulfill_condition("haveComponent","setAdventure",$location[The Old Landfill]);
		if(!buy($item[junk junk].seller,1,$item[junk junk])){
			print_warning("Buying not work. Fix code.");
			create(1,$item[junk junk]);
		}		
		print_goal("Bringing the boat to the hippy.");
		visit_url("place.php?whichplace=woods&action=woods_hippy");
	} else if(contains_text(visit_url("questlog.php?which=2"),"Give a Hippy a Boat")) {
		print_quest_complete("You have already gave a boat to a stranded hippy. Which you take back anyway.");
	} else {
		print_not_qualified("You can't do the quest.");
	}
}