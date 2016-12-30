-- [''] = '',
locTable  = {
-- �������������� ������
['<===< EXPLANATION >===>'] = '<===< ��������� >===>',
['!!! WARNING !!!'] = '!!! �������� !!!',

-- ������� ����������� ��������������
['sign indicates'] = '������� ���������',
['signs indicate'] = '�������� ���������',

['a high probability of'] = '�� ������� �����������',
['a probability of'] = '�� �����������',
['a low probability of'] = '�� ��������� �����������',

--�������� ����� ��������������
['PCB malfunction'] = '������������� ����� �����������',
['FW corruption'] = '����������� ��������������',
['spindle rotation is locked'] = '���������� �������� ��������',
['defective heads'] = '������������� ����� ��������� �������',
['bad blocks'] = '������� �������� �����������, ���������� � ��������',
['scratched surface'] = '������� ������� ����������� �����������, �������',

--���������� � �������� ��������� ����������� ������.
['A large number of bad blocks at the beginning, middle and end of the drive with a high degree of probability indicate a malfunction of one of the heads.'] = '������� ���������� ������ ������ � ������, � ����� � � �������� ����� � ������� ����� ����������� �������� ������������� ���.',
['Presence of bad blocks at the beginning, middle and end of the drive indicate a malfunction of one of the heads.'] = '������ ������ � ������, � ����� � � �������� ����� ����� �������� ������������� ���.',
['In the process of testing revealed a large number of sectors that are read incorrectly.'] = '������������ ������� ������� ���������� ��������, ���������� � ��������.',
['In the process of testing revealed sectors that are read incorrectly.'] = '������������ ������� �������, ���������� � ��������',

--������������� �������������� �� ������ �������� ��������� SMART
['S.M.A.R.T. attributes analysis indicates the likelihood of the presence of unreadable sectors.'] = '������ ��������� SMART ���������� ����������� ������� ���������� ��������.',
['A non-zero value of the attribute 184 may indicate a problem with the electronics board or controller, or cable or contact, or to strong electromagnetic interference.'] = '�������� �� ���� �������� �������� 184 ����� ��������� �� ������������� ����� �����������, ���� �����������, ���� ������ ��� ��������, ���� �� ������� �� ������.',
['A non-zero value of the attribute 199 may be a problem. This is either a cable or a buffer memory or firmware error.'] = '�� ������� �������� �������� 199 ����� ��������� �� �������������. ��� ���� ������, ���� �������� ���, ���� ������ ��������.',
['A non-zero value of the attribute 197 may indicate a problem with bad sectors.'] = '�������� 197 �������� SMART ���������� ������� ���������� ��������, ��� ����� ��������� �� �������� � ������������.',
['A non-zero value of the attribute 197 indicate a problem with bad sectors.'] = '�������� 197 �������� SMART ���������� ������� ���������� ���������� ��������, ��� ����� � ������� ����� ����������� ��������� �� �������� � ������������.',

--�������������� �� ������ ��������� SMART
['Number of on / off disk is too large.'] = '�������� ��������! ����� ������� ���������� ���������/���������� �����.',
['The first signs of disc wear.'] = '�������� ��������! ��������� ������ �������� ������ �����.',
['S.M.A.R.T. attributes analysis indicates spindle motor start problems.'] = '�������� ��������! ����������� ���� ������������� �������� � ���������� ��������.',
['Frequent recalibration may indicate the degradation of the surface and of the head.'] = '�������� ��������! ������ ������������ ����� �������� ���������� ����� � �����������.',
['Perhaps the problem with the cable or controller.'] = '�������� ��������! �������� �������� � ������� ��� ������������.',
['Drive is overheated.'] = '�������� ��������! ���������� �����������.',
['Too much parking/unparking of the heads.'] = '�������� ��������! ������� ������� ���������� ��������/����������� ���.',
['Drive has a problem with the recording, perhaps a consequence of general wear and tear.'] = '�������� ��������! ���� ����� �������� � �������, �������� ��� ��������� ������ ������.',
['The sensor recorded freefall.'] = '�������� ��������! ������ ������������ ��������� �������.',

--�� �������������� �����
['"Buzz" sound of undetected drive give high probability of jammed spidel.'] = '������������� ��� ����������� ���� "�����" ��������� �� ������� ����������� ���������� �������� � ����������� ��� ������������ ��������.',
['"Skirr" sound of undetected drive give high probability of scratched surface.'] = '���������/����������� ���� ��������� �� ������� ����������� ����������� ����������� ��������.',
['"Knocks" sound of undetected drive give probability of heads and/or surface damage, and low probability of PCB damage or scratched surface.'] = '������������� ���� ��������� �� ����������� ����������� ������� �/��� ����������� � ������ ����������� ����������� ����������� .',
['"Knocks" sound from drive, with not original ROM may mean that firmware not compatable.'] = '������������� ���� � ����� � �� ������������ ��� ��������� �� ������� ����������� �� �������������� �������������� ��� � ����� .',
['"Knocks" sound from drive with electrical dameged or with PCB dameged or with smell of burning may mean high probability of PCB mulfunction probability of bad heads and low probability of bad blocks and scratched.'] = '������������� ���� � ����� � ������������ ������ ��� � ������� ������� �������� �� ������� ����������� ������������� �����, ����������� ������������� ��� � ������ ����������� ��� ������ � �����������.',
['"Knocks" sound from drive with mechanical shock may mean high probability of heads mulfunction and probability of platter scratched or probability of bad blocks.'] = '������������� ���� � ����������/���������� ����� ��������� �� ������� ����������� ����������� ��� � ����������� ����������� � ���������� ��� �������� .',
['"Normal" sound of undetected drive mean high probability of firmvare corrupt and low probability of bad blocks or PCB mulfunction or heads mulfunction.'] = '���������� ���� � ����������������� ����� �������� �� ������� ����������� ���� �������������� � ������ ����������� ��� �������� ��� ������������ ����� ��� ������������� ���.',
['"Normal" sound of undetected and shoked drive mean high probability of firmvare corrupt and bad blocks and probability of scratched or heads mulfunction.'] = '���������� ���� � ����������/���������� ����� ��������� �� ������� ����������� ���� �������������� � ��� �������� � ����������� ����������� ����������� ��� ����������� ��� .',
['"Normal" sound of undetected drive whith not original ROM mean high probability of firmvare incompatible and probability PCB mulfunction and low probability of bad blocks or heads mulfunction.'] = '���������� ���� � ����� � �� ������������ ��� ��������� �� ������� ����������� �� ������������� �������������� ��� � ����� � ������ ����������� ��� �������� ��� ������������� ���.',
['"Silence" sound from drive, with not origginal ROM high probability of firmvare incompatable.'] = '������ ��� ������ ������� � ����� � �� ������������ ��� �������� �� ������� ����������� �� ������������� �������������� ��� � �����.',
['"Silence" sound from drive in original state mean probability of PCB mulfunction or heads mulfunction.'] = '������ ��� ������ ������� � ����� � ������������ ��������� �� ��������������� ������� ������������ ��������� �� ����������� ������������ ����� ��� ������������� ��� .',
['"Silence" sound from drive suspected that PCB have a problem mean high probability of PCB mulfunction and probability of heads mulfunction.'] = '������ ��� ������ ������� � ����� � �������������� ������������� ���� ������ ������� ��������� �� ������� ����������� ������������� ����� � ������ ����������� ������������� ���.',

--��������� ������
['The last string'] = '��������� ������'
}