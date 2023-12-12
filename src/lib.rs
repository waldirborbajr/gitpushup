use regex::Regex;

pub fn find_git_command<'a>(content: &'a str) -> Option<&'a str> {
  let re = Regex::new(r"git push[^\n]+").expect("Faield to create regular expression");
  let ma = re.find(content)?;
  Some(ma.as_str())
}
