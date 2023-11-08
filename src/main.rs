mod version;

use version::show_version;

mod git;
use git::gitpush;

fn main() {
    println!("{}", show_version());

    gitpush();
}
