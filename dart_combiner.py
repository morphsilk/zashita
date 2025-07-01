import os
import hashlib
import time
from datetime import datetime
import json

def get_file_hash(filepath):
    """Вычисляет хеш содержимого файла для отслеживания изменений"""
    try:
        with open(filepath, 'rb') as f:
            return hashlib.md5(f.read()).hexdigest()
    except Exception as e:
        print(f"Ошибка чтения файла {filepath}: {e}")
        return None

def update_combined_file(output_file, file_content_map):
    """Полностью перезаписывает объединённый файл с актуальным содержимым"""
    try:
        with open(output_file, 'w', encoding='utf-8') as out:
            out.write(f"// Combined Dart files\n// Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            
            # Сортируем файлы по алфавиту для удобства
            for relative_path in sorted(file_content_map.keys()):
                content = file_content_map[relative_path]
                out.write(f"\n\n// ===== File: {relative_path} =====\n")
                out.write(f"// Last updated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
                out.write(content)
        return True
    except Exception as e:
        print(f"Ошибка записи в файл {output_file}: {e}")
        return False

def read_dart_files(project_dir, tracked_files):
    """
    Читает все файлы .dart в папке lib и подпапках,
    возвращает актуальное содержимое файлов и флаг изменений
    """
    updated = False
    lib_dir = os.path.join(project_dir, 'lib')
    file_content_map = {}
    found_files = []
    
    if not os.path.exists(lib_dir):
        print(f"Ошибка: Папка 'lib' не найдена в {os.path.abspath(project_dir)}")
        return False, tracked_files, file_content_map
    
    print(f"Сканируем папку: {lib_dir}")
    
    for root, dirs, files in os.walk(lib_dir):
        # Пропускаем скрытые папки (начинающиеся с точки)
        dirs[:] = [d for d in dirs if not d.startswith('.')]
        
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                relative_path = os.path.relpath(filepath, project_dir)
                found_files.append(relative_path)
                
                current_hash = get_file_hash(filepath)
                if current_hash is None:
                    continue  # Пропускаем файлы с ошибками
                
                try:
                    with open(filepath, 'r', encoding='utf-8') as f:
                        content = f.read()
                    file_content_map[relative_path] = content
                except Exception as e:
                    print(f"Ошибка чтения файла {filepath}: {e}")
                    continue
                
                # Проверяем, изменился ли файл
                if relative_path not in tracked_files:
                    print(f"Новый файл: {relative_path}")
                    updated = True
                elif tracked_files[relative_path] != current_hash:
                    print(f"Файл изменен: {relative_path}")
                    updated = True
                
                # Обновляем хеш в любом случае
                tracked_files[relative_path] = current_hash
    
    # Проверяем удаленные файлы
    for filepath in list(tracked_files.keys()):
        if filepath not in found_files:
            print(f"Файл удален: {filepath}")
            updated = True
            del tracked_files[filepath]
    
    print(f"Найдено {len(found_files)} Dart файлов")
    return updated, tracked_files, file_content_map

def main():
    # Настройки
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_dir = script_dir
    output_file = os.path.join(script_dir, 'combined_dart_code.txt')
    state_file = os.path.join(script_dir, 'file_hashes.json')
    
    print(f"\n{'='*50}")
    print(f"Директория проекта: {project_dir}")
    print(f"Папка lib: {os.path.join(project_dir, 'lib')}")
    print(f"Выходной файл: {output_file}")
    print(f"Файл состояний: {state_file}")
    print(f"Текущее время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"{'='*50}")
    
    # Загружаем предыдущие хеши файлов
    tracked_files = {}
    if os.path.exists(state_file):
        try:
            with open(state_file, 'r') as f:
                tracked_files = json.load(f)
            print(f"Загружено {len(tracked_files)} отслеживаемых файлов")
        except (json.JSONDecodeError, FileNotFoundError) as e:
            print(f"Ошибка загрузки файла состояний: {e}")
            tracked_files = {}
    
    # Проверяем изменения и получаем актуальное содержимое
    updated, tracked_files, file_content_map = read_dart_files(project_dir, tracked_files)
    
    if updated:
        print("Обнаружены изменения в Dart-файлах")
        if update_combined_file(output_file, file_content_map):
            print(f"Успешно обновлен файл: {output_file}")
        else:
            print("Не удалось обновить файл")
    else:
        print("Изменений не обнаружено.")
    
    # Сохраняем текущие хеши файлов
    try:
        with open(state_file, 'w') as f:
            json.dump(tracked_files, f, indent=2)
        print(f"Сохранены хеши для {len(tracked_files)} файлов")
    except Exception as e:
        print(f"Ошибка сохранения файла состояний: {e}")

if __name__ == "__main__":
    print("Отслеживание изменений в Dart-файлах... (Ctrl+C для остановки)")
    
    try:
        while True:
            main()
            time.sleep(5)  # Увеличим интервал для тестирования
    except KeyboardInterrupt:
        print("\nСкрипт остановлен.")