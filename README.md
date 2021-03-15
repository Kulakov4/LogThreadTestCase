Задание1. Задание на потоки и объекты

Цель: продемонстрировать опыт разработки многопоточных приложений и владения
объектно-ориентированным программированием.

Для реализации потоков необходимо использовать класс TThread, а не таймер.
Создать несколько потоков-объектов, каждый из них периодически (период должен задаваться)
создает сообщение и пишет в файл.

Для записи в файл нужно использовать общий объект (Logger). Для записи сообщения ему
передается текст сообщения и его статус, а он пишет в файл сообщение, статус, идентификатор
потока и время.

Статусы: Critical, Warning, Info.

Также класс Logger должен:
1) Хранить в памяти последние 10 сообщений.
2) Реализовывать удаление из файла старых сообщений (старее, чем на данное количество
минут). 

Удаление должно вызываться периодически (Период задается).
В приложении д.б. интерфейс отображения 10 сообщений из памяти Logger-а.

Классы логгера и формирования сообщений должны быть реализованы так, чтобы их можно было
использовать в приложении как с графическим интерфейсом, так и без него.

Количество потоков формирования сообщений, время жизни и периодичность очистки старых
сообщений из файла, имя файла лога должны задаваться в константах (либо читаться из файла
настроек – продвинутый уровень)
