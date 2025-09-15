import json
from datetime import datetime

def read_json(filepath):
    try:
        with open(filepath, "r") as file:
            return json.load(file)
    except (FileNotFoundError, json.JSONDecodeError):
        print(f"Warning: {filepath} not found or invalid JSON")
        return []

def process_json_folders(folders, file_name):
    content = []
    for folder in folders:
        file_content = read_json(f"{folder}/{file_name}")
        if file_content:
            if "event" in file_content[0]:
                formatted_content = format_events(file_content)
            else:
                formatted_content = format_grading(file_content)
            content.append(f"### {folder}\n\n" + formatted_content)
    return "\n\n".join(content)

def format_events(events):
    content = ""
    current_date = datetime.now()
    for event in events:
        if event['date'].lower() == "tbd":
            emoji = "⚪"  # Gray square for TBD
            days_text = ""
        else:
            event_date = datetime.strptime(event['date'], "%Y-%m-%d")
            delta_days = (event_date - current_date).days
            if delta_days < 0:
                emoji = "🟢"  # Green square for past dates
                days_text = f"({abs(delta_days)} days ago)"
            elif delta_days <= 7:
                emoji = "🔴"  # Red square for events less than 7 days away
                days_text = f"(in {delta_days} days)"
            else:
                emoji = "🟡"  # Yellow square for events more than 7 days away
                days_text = f"(in {delta_days} days)"
        content += f"{emoji} **{event['event']}**  \n  Date: {event['date']} {days_text}  \n  Time: {event['time']}  \n  Location: {event['location']}\n\n"
    return content.strip()

def format_grading(grading):
    content = "### Grading Breakdown\n\n"
    content += "| Assessment | Weight |\n"
    content += "|------------|--------|\n"
    for item in grading:
        content += f"| {item['type']} | {item['percent']*100:.0f}% |\n"
    return content.strip()

def generate():
    folders = ["2.001", "21m.361", "6.230", "6.250", "6.300"]
    categories = ["grading.json", "dates.json"]
    template_file = "template.md"
    output_file = "README.md"
    
    try:
        with open(template_file, "r") as file:
            template_content = file.read().strip()
    except FileNotFoundError:
        print(f"Warning: {template_file} not found")
        return
    
    for category in categories:
        category_content = process_json_folders(folders, category)
        template_content = template_content.replace(f"<!--{category.replace('.json', '.md')}-->", category_content)
    
    with open(output_file, "w") as file:
        file.write(template_content + "\n")

if __name__ == "__main__":
    generate()
