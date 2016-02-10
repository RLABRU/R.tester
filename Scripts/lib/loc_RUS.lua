-- [''] = '',
LocTable  = {
-- Степени вероятности неисправностей
['sign(s) point to a low probability of'] = 'признак(ов) указывает на небольшую вероятность',
['sign(s) point to a probability of'] = 'признак(ов) указывает на вероятность',
['sign(s) point to a high probability of'] = 'признак(ов) указывает на высокую вероятность',

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

--Предупреждения на основе атрибутов SMART
['SMART attribute #4 value is too high.'] = 'Абсолютное значени SMART атрибута 4 очень велико, обратите внимание.',

['The last string'] = 'Последняя строка'
}