use std::{fs::read_to_string, collections::HashMap};


#[derive(Debug)]
struct GameData {
    id: i16,
    sets:Vec<Vec<(i32, String)>>
}

fn parse_set_value(str: &str) -> Option<(i32, String)> {
    let mut it = str.trim().split(" ");
    if let (Some(v), Some(key)) = (it.next(), it.next()) {
        return Some((v.parse::<i32>().unwrap(), key.to_string()));
    }
    return None;
}

fn parse_set(str: &str) -> Vec<(i32, String)> {
    return str.split(",")
        .map(parse_set_value)
        .filter(|maybe| maybe.is_some())
        .map(|o| o.unwrap())
        .collect();
}

fn parse_game_sets(str: &str) -> Vec<Vec<(i32, String)>> {
    return str.split(";")
        .map(parse_set)
        .collect();
}

fn parse_game_id(data: &str) -> Option<i16> {
    let mut it = data.split(" ");
    if let (Some(_), Some(game_id)) = (it.next(), it.next()) {
        return Some(game_id.parse::<i16>().unwrap());
    }
    return None;
}



fn parse_line(str: &str) -> Option<GameData> {
    let mut data = str.split(":");
    if let (Some(game_id_data), Some(game_sets_data)) = (data.next(), data.next()) {
        if let (Some(game_id), game_sets) = (parse_game_id(game_id_data), parse_game_sets(game_sets_data)) {
            return Some(GameData{
                id: game_id,
                sets: game_sets
            });
        }
    }
    return None
}

fn parse_file(path: &str) -> Vec<GameData> {
    read_to_string(path) 
    .unwrap()  // panic on possible file-reading errors
    .lines()  // split the string into an iterator of string slices
    .map(parse_line)
    .filter(|maybe| maybe.is_some())
    .map(|o| o.unwrap())
    .collect()
}

fn game_is_possible(game:&GameData, input:&HashMap<String, i32>) -> bool {
    for elm in &game.sets {
        for (v, color) in elm {
            let max = input.get(color).unwrap_or(&(0 as i32));
            if (v > max) {
                return false;
            }
        }
    }
    return true;
}


fn calc(data:&Vec<GameData>, input:&HashMap<String, i32>) -> i16 {
    return data
        .iter()
        .filter(|g| game_is_possible(g, input))
        .map(|g| g.id)
        .sum();
}

fn calc_power_of_min(data:&GameData) -> i64 {
    let mut h = HashMap::new();
    for elm in &data.sets {
        for (v, color) in elm {
            let stored_v = h.get(color).unwrap_or(&(0 as i32));
            if (v > stored_v) {
                h.insert(color, *v);
            }
        }
    }

    let mut result = 1 as i64;
    for (_, v) in h {
        result *= v as i64;
    }

    return result;
}

fn calc_part2(data:&Vec<GameData>) -> i64 {
    return data.iter()
        .map(|g| calc_power_of_min(g))
        .sum()
}



fn main() {
    let mut data = Vec::new();
    let input = HashMap::from([("red".to_string(), 12 as i32), ("green".to_string(), 13 as i32), ("blue".to_string(), 14 as i32)]);
    
    data = parse_file("data/sample1.txt");
    let sum1 = calc(&data, &input);

    let mut data_input1 = Vec::new();
    data_input1 = parse_file("data/input1.txt");
    let sum2 = calc(&data_input1, &input);

    let mut data_sample2 = Vec::new();
    data_sample2 = parse_file("data/sample2.txt");
    let sum3 = calc_part2(&data_sample2);

    let mut data_input2 = Vec::new();
    data_input2 = parse_file("data/input2.txt");
    let sum4 = calc_part2(&data_input2);

    print!("{sum1} {sum2} {sum3} {sum4}");
}

