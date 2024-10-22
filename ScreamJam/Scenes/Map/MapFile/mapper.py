import argparse
from PIL import Image, ImageDraw, ImageFont

def is_black(color, tolerance):
    return color[0] <= tolerance and color[1] <= tolerance and color[2] <= tolerance

def map_from_image(image_path, output_path, tolerance = 50):
    img = Image.open(image_path)
    img = img.convert('RGB')

    case_size = 16
    width, height = img.size

    if width % case_size != 0 or height % case_size != 0:
        raise ValueError("L'image doit être divisible par la taille des cases (16x16).")

    num_cases_x = width // case_size
    num_cases_y = height // case_size

    grid = []

    for y in range(num_cases_y):
        row = []
        for x in range(num_cases_x):
            box = img.crop((x * case_size, y * case_size, (x + 1) * case_size, (y + 1) * case_size))
            avg_color = box.resize((1, 1)).getpixel((0, 0))

            if is_black(avg_color, tolerance):
                row.append('0')
            else:
                row.append('1')

        grid.append(' '.join(row))

    with open(output_path, 'w') as f:
        for line in grid:
            f.write(line + '\n')

def draw_from_txt(input_path, output_path, coordinates = False):
    with open(input_path, 'r') as f:
        lines = f.readlines()

    grid = []
    case_size = 15
    max_cases = 0
    offset = 0

    for line in lines:
        row = line.strip().split()
        max_cases = max(max_cases, len(row))
        grid.append(row)

    for i in range(len(grid)):
        while len(grid[i]) < max_cases:
            grid[i].append('0')

    if not grid:
        raise ValueError("Empty input.")

    if(coordinates):
        offset = 15
    img_width = max_cases * case_size + (max_cases + 1) + offset
    img_height = len(grid) * case_size + (len(grid) + 1) + offset
    image = Image.new('RGB', (img_width, img_height), 'white')
    draw = ImageDraw.Draw(image)

    for y in range(len(grid)):
        for x in range(max_cases):
            x_pos = x * case_size + (x + 1) + offset
            y_pos = y * case_size + (y + 1) + offset
            color = 'black' if grid[y][x] == '0' else 'white'
            draw.rectangle([x_pos, y_pos, x_pos + case_size, y_pos + case_size], fill=color)

    for y in range(len(grid) + 1):
        y_pos = y * (case_size + 1) + offset
        draw.line([(offset, y_pos), (img_width, y_pos)], fill='lightgray')
    for x in range(max_cases + 1):
        x_pos = x * (case_size + 1) + offset
        draw.line([(x_pos, offset), (x_pos, img_height)], fill='lightgray')

    if (coordinates):
        #Draw coordinates guide as text
        font = ImageFont.load_default()
        for x in range(max_cases):
            x_pos = x * case_size + (x + 1) + offset + case_size // 2
            draw.text((x_pos, 5), str(x), fill='black', font=font, anchor='mm')
        for y in range(len(grid)):
            y_pos = y * case_size + (y + 1) + offset + case_size // 2
            draw.text((5, y_pos), str(y), fill='black', font=font, anchor='mm')
    image.save(output_path)

def main():
    parser = argparse.ArgumentParser(description='Draw or read map layouts.')
    subparsers = parser.add_subparsers(dest='command')

    analyze_parser = subparsers.add_parser('map', help='Create map from image.')
    analyze_parser.add_argument('input_path', help='Input image path.')
    analyze_parser.add_argument('output_path', help='Output map path.')
    analyze_parser.add_argument('--tolerance', type=float, default=50.0, help='Tolerance for black shade (def = 50.0).')

    create_parser = subparsers.add_parser('draw', help='Create image from map.')
    create_parser.add_argument('input_path', help='Input map path.')
    create_parser.add_argument('output_path', help='Output image path.')
    create_parser.add_argument('--add_guide', type=bool, default=False, help='Draw coordinates guide as text.')

    args = parser.parse_args()

    if args.command == 'map':
        map_from_image(args.input_path, args.output_path, args.tolerance)
    elif args.command == 'draw':
        draw_from_txt(args.input_path, args.output_path, args.add_guide)

if __name__ == '__main__':
    main()