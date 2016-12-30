-- [''] = '',
locTable  = {
-- Форматирование вывода
['<===< EXPLANATION >===>'] = '<===< ПОЯСНЕНИЕ >===>',
['!!! WARNING !!!'] = '!!! ВНИМАНИЕ !!!',

-- Степени вероятности неисправностей
['sign indicates'] = 'признак указывает',
['signs indicate'] = 'признака указывают',

['a high probability of'] = 'на высокую вероятность',
['a probability of'] = 'на вероятность',
['a low probability of'] = 'на небольшую вероятность',

--Названия типов неисправностей
['PCB malfunction'] = 'неисправности платы электроники',
['FW corruption'] = 'повреждения микропрограммы',
['spindle rotation is locked'] = 'блокировки вращения шпинделя',
['defective heads'] = 'неисправности блока магнитных головок',
['bad blocks'] = 'наличия участков поверхности, читающихся с ошибками',
['scratched surface'] = 'наличия тяжелых повреждений поверхности, царапин',

--Объяснения к правилам обработки результатов тестов.
['A large number of bad blocks at the beginning, middle and end of the drive with a high degree of probability indicate a malfunction of one of the heads.'] = 'Большое количество ошибок чтения в начале, в конце и в середине диска с высокой долей вероятности означает неисправность БМГ.',
['Presence of bad blocks at the beginning, middle and end of the drive indicate a malfunction of one of the heads.'] = 'Ошибки чтения в начале, в конце и в середине диска могут означать неисправность БМГ.',
['In the process of testing revealed a large number of sectors that are read incorrectly.'] = 'Тестирование выявило большое количество секторов, читающихся с ошибками.',
['In the process of testing revealed sectors that are read incorrectly.'] = 'Тестирование выявило сектора, читающихся с ошибками',

--Предположение неисправностей на основе значений атрибутов SMART
['S.M.A.R.T. attributes analysis indicates the likelihood of the presence of unreadable sectors.'] = 'Анализ атрибутов SMART показывает вероятность наличия нечитаемых секторов.',
['A non-zero value of the attribute 184 may indicate a problem with the electronics board or controller, or cable or contact, or to strong electromagnetic interference.'] = 'Отличное от нуля значение атрибута 184 может указывать на неисправность платы электроники, либо контроллера, либо кабеля или контакта, либо на сильные ЭМ помехи.',
['A non-zero value of the attribute 199 may be a problem. This is either a cable or a buffer memory or firmware error.'] = 'Не нулевое значение атрибута 199 может указывать на неисправность. Это либо кабель, либо буферное ОЗУ, либо ошибка прошивки.',
['A non-zero value of the attribute 197 may indicate a problem with bad sectors.'] = 'Значение 197 атрибута SMART показывает наличие нечитаемых секторов, что может указывать на проблемы с поверхностью.',
['A non-zero value of the attribute 197 indicate a problem with bad sectors.'] = 'Значение 197 атрибута SMART показывает большое количество нечитаемых секторов, что может с высокой долей вероятности указывает на проблемы с поверхностью.',

--Предупреждения на основе атрибутов SMART
['Number of on / off disk is too large.'] = 'Обратите внимание! Очень большое количество включений/выключений диска.',
['The first signs of disc wear.'] = 'Обратите внимание! Появились первые признаки износа диска.',
['S.M.A.R.T. attributes analysis indicates spindle motor start problems.'] = 'Обратите внимание! Устройством были зафиксированы проблемы с раскруткой шпинделя.',
['Frequent recalibration may indicate the degradation of the surface and of the head.'] = 'Обратите внимание! Частые рекалибровки могут означать деградацию голов и поверхности.',
['Perhaps the problem with the cable or controller.'] = 'Обратите внимание! Возможно проблемы с кабелем или контроллером.',
['Drive is overheated.'] = 'Обратите внимание! Устройство перегрелось.',
['Too much parking/unparking of the heads.'] = 'Обратите внимание! Слишком большое количество парковок/распарковок БМГ.',
['Drive has a problem with the recording, perhaps a consequence of general wear and tear.'] = 'Обратите внимание! Диск имеет проблемы с записью, возможно это следствие общего износа.',
['The sensor recorded freefall.'] = 'Обратите внимание! Датчик зафиксировал свободное падение.',

--Не определяющиеся диски
['"Buzz" sound of undetected drive give high probability of jammed spidel.'] = 'Повторяющийся или однократный звук "Бзззз" указывает на высокую вероятность прилипания гололовк к поверхности или заклинивания шпинделя.',
['"Skirr" sound of undetected drive give high probability of scratched surface.'] = 'Свистящий/скрежетащий звук указывает на высокую вероятность запиливания поверхности головкам.',
['"Knocks" sound of undetected drive give probability of heads and/or surface damage, and low probability of PCB damage or scratched surface.'] = 'Повторяющийся стук указывает на вероянность повреждения головок и/или поверхности и низкую вероятность запиливания поверхности .',
['"Knocks" sound from drive, with not original ROM may mean that firmware not compatable.'] = 'Повторяющийся стук у диска с не оригинальным ПЗУ указывает на высокую вероянность не свовместимости микропрограммы ПЗУ и диска .',
['"Knocks" sound from drive with electrical dameged or with PCB dameged or with smell of burning may mean high probability of PCB mulfunction probability of bad heads and low probability of bad blocks and scratched.'] = 'Повторяющийся стук у диска с поврежденной платой или с запахом горения указывет на высокую вероянность неисправности платы, вероятность неисправности БМГ и низкую вероянность бэд блоков и запиливания.',
['"Knocks" sound from drive with mechanical shock may mean high probability of heads mulfunction and probability of platter scratched or probability of bad blocks.'] = 'Повторяющийся стук у ударенного/уроненного диска указывает на высокую вероянность повреждения БМГ и вероянность запиливания с появлением бэд секторов .',
['"Normal" sound of undetected drive mean high probability of firmvare corrupt and low probability of bad blocks or PCB mulfunction or heads mulfunction.'] = 'Нормальный звук у неопределяющегося диска указывет на высокую вероянность сбоя микропрограммы и низкую вероянность бэд секторов или несправность платы или неисправность БМГ.',
['"Normal" sound of undetected and shoked drive mean high probability of firmvare corrupt and bad blocks and probability of scratched or heads mulfunction.'] = 'Нормальный звук у ударенного/уроненного диска указывает на высокую вероянность сбоя микропрограммы и бэд секторов и вероянность запиливания поверхности или повреждения БМГ .',
['"Normal" sound of undetected drive whith not original ROM mean high probability of firmvare incompatible and probability PCB mulfunction and low probability of bad blocks or heads mulfunction.'] = 'Нормальный звук у диска с не оригинальным ПЗУ указывает на высокую вероянность не совместимости микропрограммы ПЗУ и диска и низкую вероянность бэд секторов или неисправность БМГ.',
['"Silence" sound from drive, with not origginal ROM high probability of firmvare incompatable.'] = 'Тишина при подаче питания у диска с не оригинальным ПЗУ укзывает на высокую вероятность не совместимости микропрограммы ПЗУ и диска.',
['"Silence" sound from drive in original state mean probability of PCB mulfunction or heads mulfunction.'] = 'Тишина при подаче питания у диска в оригинальном состоянии не подвергавшемуся внешним воздействиям указывает на вероятность нисправности платы или неисправность БМГ .',
['"Silence" sound from drive suspected that PCB have a problem mean high probability of PCB mulfunction and probability of heads mulfunction.'] = 'Тишина при подаче питания у диска с электрическими повреждениями иизи запаха горения указывает на высокую вероянность неисправности платы и низкую вероянность неисправности БМГ.',

--Последняя строка
['The last string'] = 'Последняя строка'
}