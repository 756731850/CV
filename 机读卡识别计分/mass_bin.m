close all;
clc;

FileNames_1 = dir('./img/');
FileNames_2 = dir('./img/����ͼƬ');
FileNames_3 = dir('./img/��ģ�����ͼƬ');

%WindowXY = floor(sqrt(length(FileNames_2)));
%figure();
for n=3:length(FileNames_2)
    file = ['./img/����ͼƬ/',FileNames_2(n).name];
    I = imread(file);
    I = imresize(I, [640, 360]);    % ͼ���С�޸ģ���ֹ�ֱ��ʹ���ʹ����ʱ��̫��
    [height, width, pass] = size(I);
    if pass > 1 % �ж��Ƿ��ǻҶ�ͼ��
        I = rgb2gray(I); % �Ҷ�ת�� 
    end
    Level = graythresh(I);
    Bg = adaptthresh(I, Level, 'Statistic', 'median',  'ForegroundPolarity','dark'); % ����Ӧ�˲�
    Bg = Bg * 255;
    Bg = uint8(Bg);
    tempI = 255 - Bg + I;
    Binary = im2double(tempI).^16;   % ����
    %WindowPos = mod(n, WindowXY) + floor(n / WindowXY);
    figure();
    %subplot(WindowXY + 1, WindowXY + 1, WindowPos); 
    imshow(Binary); title(FileNames_2(n).name);
end