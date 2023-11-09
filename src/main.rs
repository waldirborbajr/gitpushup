mod git;
mod randmessage;
mod version;

use git::gitpush;
use randmessage::rand_message;
use version::show_version;

fn main() {
    let mut param = std::env::args().skip(1);

    let message = if let Some(content) = param.next() {
        if content.is_empty() {
            rand_message().to_string()
        } else {
            content.to_string()
        }
    } else {
        rand_message().to_string()
    };

    // Display the version
    println!("{}", show_version());

    gitpush(&message);
}
