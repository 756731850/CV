
close all;
clc;

%% ��ȡͼƬ
I = imread('./img/��ģ�����ͼƬ/ƻ��6s (20).jpg');
I = imresize(I, [640, 360]);    % ͼ���С�޸ģ���ֹ�ֱ��ʹ���ʹ����ʱ��̫��
[M, N, pass] = size(I);
if pass > 1 % �ж��Ƿ��ǻҶ�ͼ��
    I = rgb2gray(I); % �Ҷ�ת�� 
end
%I = histeq(I); % ͼ����ǿ�������ֻ�����������Ӱ��
figure();
subplot(131);
imshow(I);title('ԭͼ');

%% ͼ��Ԥ����
Level = graythresh(I);
AdaptT = adaptthresh(I, 'Statistic', 'median',  'ForegroundPolarity', 'dark'); % ����Ӧ��ֵ
Bg = AdaptT * 255; % ��չ
Bg = uint8(Bg); 
subplot(132);
imshow(Bg);title('����(��ֵ�˲�)');
tempI = 255 - Bg + I;
subplot(133);
imshow(tempI);title('����Ľ��');
Binary = histeq(tempI);  % ֱ��ͼ���⻯
figure(); subplot(142); imshow(Binary); title('ֱ��ͼ���⻯'); % ��ʾ��ֵ��ͼ��
Binary = adapthisteq(tempI); % ����Ӧֱ��ͼ���⻯
subplot(143); imshow(Binary); title('����Ӧֱ��ͼ���⻯'); % ��ʾ��ֵ��ͼ��
Binary = imbinarize(I, AdaptT); % ֱ�Ӷ�ֵ��
subplot(141); imshow(Binary); title('ֱ��ʹ������Ӧ��ֵ'); % ��ʾ��ֵ��ͼ��
Binary = im2double(tempI).^16;   % ����
subplot(144); imshow(Binary); title('����'); % ��ʾ��ֵ��ͼ��
BinaryImage = Binary;

h_point = detectHarrisFeatures(Binary); % Harris�ǵ���

% ROI���
condi_roi = regionprops(im2bw(1.0 - Binary), 'area', 'boundingbox'); % ��roi
max_area = 0;
index_k = 0;
figure(); subplot(141); imshow(Binary); title('��ֵ��');
subplot(142); imshow(Binary); title('ROI��ǵ���'); hold on;
for i=1:length(condi_roi)
    area = condi_roi(i).Area;
    if area > max_area
        max_area = area;
        index_k = i;
    end
end
roi_pos = condi_roi(index_k).BoundingBox;
rectangle('position', roi_pos, 'EdgeColor', 'r', 'lineWidth', 1);  
plot(h_point.selectStrongest(50)); % harris��������
hold off;

% houghֱ����ȡ
Binary = BinaryImage;
ROI = imcrop(Binary, roi_pos);
ROI_edge = edge(ROI, 'canny');
[H_, T_, R_] = hough(ROI_edge);
P_ = houghpeaks(H_, 20);
lines = houghlines(ROI_edge, T_, R_, P_, 'FillGap', 5, 'MinLength', 30);

% ��������ֱ��
break_vis = zeros([1, 500], 'uint8');
for i=1:length(lines)
    if break_vis(i) == 1 % ֮ǰ�Ѿ������ߵ��߼�����ˣ�����ֱ������
        continue;
    end
    for j=i+1:length(lines)
        %�����ֱ�߹�������
        if abs(lines(i).theta - lines(j).theta) <= 0 && abs(lines(i).rho - lines(j).rho) <= 0
            break_vis(j) = 1;
            continue;
        end
    end
end  

% ��ʾROI hough����ȡ���
subplot(143); imshow(ROI); title('��ROI houghֱ����ȡ���'); hold on;
max_len = 0;
for k = 1:length(lines)
    if break_vis(k) == 1
        continue;
    end
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end

% ��hough��ȡ��ֱ�߽��㣬����������������ROI��
ic = 1; % ���������
cross_point = zeros([500, 2]);  % ���潻��
for i=1:length(lines)
    if break_vis(i) == 1 % ֮ǰ�Ѿ������ߵ��߼�����ˣ�����ֱ������
        continue;
    end
    for j=i+1:length(lines)
        if break_vis(j) == 1 % ֮ǰ�Ѿ������ߵ��߼�����ˣ�����ֱ������
            continue;
        end
        a = lines(i).point1; b = lines(i).point2;
        c = lines(j).point1; d = lines(j).point2;
        denominator = (b(2) - a(2))*(d(1) - c(1)) - (a(1) - b(1))*(c(2) - d(2));
        x = ((b(1) - a(1)) * (d(1) - c(1)) * (c(2) - a(2))...
                + (b(2) - a(2)) * (d(1) - c(1)) * a(1)...
                - (d(2) - c(2)) * (b(1) - a(1)) * c(1) ) / denominator;
        y = -( (b(2) - a(2)) * (d(2) - c(2)) * (c(1) - a(1))...
                + (b(1) - a(1)) * (d(2) - c(2)) * a(2)...
                - (d(1) - c(1)) * (b(2) - a(2)) * c(2) ) / denominator;
        
        % ʡ�Գ����߽�ĵ�
        if x - size(ROI, 2) >= 20 || x <= -20 || y - size(ROI, 1) >= 20 || y <= -20
            continue
        end
        
        cross_point(ic, 1) = x; cross_point(ic, 2) = y;
        ic = ic + 1;
    end
end
cross_point(ic:500 , :) = []; % ɾ�����������ж����Ԫ��
subplot(144); imshow(ROI); title('hough��ȡֱ�ߵĽ���'); hold on;
for i=1:ic-1
    plot(cross_point(i,1), cross_point(i, 2), 'x');
end
% Ѱ�����ĵ�
centerP = mean(cross_point);
plot(centerP(1), centerP(2), 'o'); hold off;

% ȷ���߿��Ķ��㣬���������ϡ����ϡ����¡�����
disMin = zeros([1, 5]);
disMin(:) = -1e+8;
before_point(:) = [roi_pos(1), roi_pos(2)];
for i=1:ic-1
    dis_center_cross = sqrt((cross_point(i, 1) - centerP(1))^2 + (cross_point(i, 2) - centerP(2))^2);
    if cross_point(i, 1) < centerP(1) && cross_point(i, 2) < centerP(2) && disMin(1) < dis_center_cross
        disMin(1) = dis_center_cross;
        dot(1, :) = cross_point(i,:);
        dot(1, :) = before_point + dot(1, :);
    elseif cross_point(i, 1) > centerP(1) && cross_point(i, 2) < centerP(2) && disMin(2) < dis_center_cross
        disMin(2) = dis_center_cross;
        dot(2, :) = cross_point(i,:);
        dot(2, :) = before_point + dot(2, :);
    elseif cross_point(i, 1) < centerP(1) && cross_point(i, 2) > centerP(2) && disMin(3) < dis_center_cross
        disMin(3) = dis_center_cross;
        dot(3, :) = cross_point(i,:);
        dot(3, :) = before_point + dot(3, :);
    elseif cross_point(i, 1) > centerP(1) && cross_point(i, 2) > centerP(2) && disMin(4) < dis_center_cross
        disMin(4) = dis_center_cross;
        dot(4, :) = cross_point(i,:);
        dot(4, :) = before_point + dot(4, :);
    end
end

figure();
subplot(121); imshow(BinaryImage); title('�ĸ�����get��'); hold on;
for i=1: 4
    plot(dot(i, 1), dot(i, 2), 'x');
end

%% ͼ��У��
fixPoints = [roi_pos(1), roi_pos(2); roi_pos(1) + roi_pos(3), roi_pos(2);...
    roi_pos(1), roi_pos(2) + roi_pos(4); roi_pos(1) + roi_pos(3), roi_pos(2) + roi_pos(4)]; % ��ROI������������ΪfixedPoint
tfrom = fitgeotrans(dot, fixPoints, 'projective');
corrected_img = imwarp(I, tfrom);
subplot(122); imshow(corrected_img); title('ͼ��У��');

%% ѡ����ʶ��
% ��ֵ��У����ͼ��
I = corrected_img;
I_double = im2double(I);
AdaptT = adaptthresh(I, 'Statistic', 'median',  'ForegroundPolarity', 'dark'); % ����Ӧ��ֵ
tempI = 1.0 - AdaptT + I_double;
Binary = tempI .^ 16;
BinaryImage = Binary;
figure();
subplot(121); imshow(im2bw(Binary)); title('У����Ķ�ֵͼ'); hold on; 
% ROI��ȡ
condi_roi = regionprops(im2bw(Binary), 'area', 'BoundingBox');
[s_condi_roi, index] = sort([condi_roi.Area], 'descend'); % �Խṹ������,indexΪb�е���ֵ��a�ж�Ӧ������
roi(1, 1:4) = condi_roi(index(2)).BoundingBox; roi(2, 1:4) = condi_roi(index(3)).BoundingBox; 
roi(3, 1:4) = condi_roi(index(4)).BoundingBox; % ֮���Դ�index(2)��ʼ����Ϊindex(1)ΪͼƬ�������ӿ�
rectangle('position', roi(1,:), 'EdgeColor', 'r', 'lineWidth', 1);  
rectangle('position', roi(2,:), 'EdgeColor', 'r', 'lineWidth', 1);  hold off;

% ѡ���������ڲ���������
rect_choose = im2bw(imcrop(Binary, roi(1, :)));
subplot(122); imshow(rect_choose); title('ѡ����������');
ratio = size(rect_choose, 2) / 20;      % �������
first_answer_pos(1:2) = [1.2 * ratio, 1.55 * ratio];
s_row_interval = 0.25 * ratio; b_row_interval = 0.45 * ratio; % ��С����
s_col_interval = 0.3 * ratio; b_col_interval = 1.2 * ratio; % ��С�ݼ��
answer_height = 0.45 * ratio; answer_width = 0.7 * ratio;    % �𰸿ո�Ŀ��

% ѡ�����ڲ���ѡ(15*16�ľ���)
for i = 1:15
    for j = 1:16
        add_w = (j - 1) * s_col_interval + floor((j-1)/4) * b_col_interval - floor((j-1)/4) * s_col_interval; % ���ϼ��
        add_w = add_w + (j-1) * answer_width;   % ����ÿ���𰸸��ӵĿ��
        add_h = (i - 1) * s_row_interval + floor((i-1)/5) * b_row_interval - floor((i-1)/5) * s_row_interval; % ���ϼ��
        add_h = add_h + (i-1) * answer_height;  % ����ÿ���𰸸��ӵĸ߶�
        answer_mat(i, j, 1:4) = [first_answer_pos(1) + add_w, first_answer_pos(2) + add_h, answer_width, answer_height]; 
    end
end

% ��ʾ��ѡ���
hold on;
for i = 1:15
    for j = 1:16
        rectangle('position', answer_mat(i, j, :), 'EdgeColor', 'r', 'lineWidth', 1); 
    end
end
hold off;

% �����������¼����ά������
for i = 1:15
    for j = 1:4
        for k = (j-1)*4+1:j*4
            tmp_rect(:) = answer_mat(i, k, :);
            tmp_img = imcrop(rect_choose, tmp_rect(:));
            tmp_mat = tmp_img == 0;
            tmp_(k - (j-1)*4) = sum(tmp_mat(:));
        end
        [tmp_max, tmp_index] = max(tmp_);
        answer_status(i, j) = tmp_index;    
    end
end

window = figure(); uitable(window, 'Data', answer_status(:, :));

%% ����ʶ��
% ѡȡ��������
rect_number = imcrop(Binary, roi(2, :));
rect_number = im2bw(rect_number);
figure(); imshow(rect_number); hold on; 
[height, width] = size(rect_number); ratio = height / 10.0;
line_width = 0.17 * ratio;
row_1_begin_pos = [2.5 * ratio, 3.3 * ratio]; % ��һ�ŵ�һ�����ֵ�����(x, y)
row_2_begin_pos = [2.5 * ratio, 6.6 * ratio]; % �ڶ��ŵ�һ�����ֵ�����(x, y)
plot(row_1_begin_pos(1), row_1_begin_pos(2), '+');
plot(row_2_begin_pos(1), row_2_begin_pos(2), '+');
% �����һ�ŵ�����ͼ��
row_1(1, 1:2) = [row_1_begin_pos(1) + line_width, row_1_begin_pos(2) + line_width];
row_1(1, 3:4) = [ratio, ratio*2];
for i = 2:6
    row_1(i, 1:2) = [row_1(i-1, 1) + row_1(i-1, 3) + line_width, row_1(i-1, 2)]; 
    row_1(i, 3:4) = [row_1(i-1, 3), row_1(i-1, 4)];
end
for i = 1:6
    rectangle('position', row_1(i, :), 'EdgeColor', 'r', 'lineWidth', 1);
end

% ����ڶ��ŵ�����ͼ��
row_2(1, 1:2) = [row_2_begin_pos(1) + line_width, row_2_begin_pos(2) + line_width];
row_2(1, 3:4) = [ratio, ratio*2];
for i = 2:18
    row_2(i, 1:2) = [row_2(i-1, 1) + row_2(i-1, 3) + line_width, row_2(i-1, 2)]; 
    row_2(i, 3:4) = [row_2(i-1, 3), row_2(i-1, 4)];
end
for i = 1:18
    rectangle('position', row_2(i, :), 'EdgeColor', 'r', 'lineWidth', 1);
end
hold off;


% ����ѵ�����ݼ�
digitpath = './digittest/ѵ��';
digitpaths = dir(digitpath);
cnt = 0;
for i = 3: length(digitpaths)
    filename = dir([digitpath, '/', digitpaths(i).name, '/']);
    for j = 3: length(filename)
        cnt = cnt + 1;
        trainSets(cnt).File = [digitpath, '/', digitpaths(i).name, '/', filename(j).name];
        trainSets(cnt).Label = double(i-3);
    end
end
digitNumber = cnt;

% ��ȡѵ����������
cellSize = [4, 4];
tp_image = readImage(trainSets, 1);
imgSize = size(tp_image);
[hog_4x4, ~] = extractHOGFeatures(tp_image,'CellSize',[4 4]);
hogFeatureSize = length(hog_4x4);
trainingFeatures = extracthog(trainSets,digitNumber,imgSize,cellSize,hogFeatureSize); % ��ȡhog����
trainingLabels = cat(1, trainSets.Label);

% ѵ��������
labelNumber = 10;
model = cell(labelNumber,1);
for k=0: labelNumber-1
    label=trainingLabels==k;
    model{k+1} = svmtrain(trainingFeatures,label);%fitcsvm
end

% ��ȡͼ�������ֵ�����ֵ
row_1_Features = extracthog_frame(row_1, rect_number, imgSize,cellSize,hogFeatureSize); % ��ȡhog����
row_2_Features = extracthog_frame(row_2, rect_number, imgSize,cellSize,hogFeatureSize); % ��ȡhog����

% ʶ���һ�����ֲ���ʾʶ����
for j=1: size(row_1, 1);
    for k=1: labelNumber
       classp(j, k) = svmclassify(model{k}, row_1_Features(j, :));
    end
    p = find(classp(j, :)==1);
    if ~isempty(p)
        labelp(j).predict=p-1;
        row_1_data(j, 1) = p(1) - 1;
    else
        row_1_data(j, 1) = -1;
    end
end
window = figure();
table_ = uitable(window, 'Data', row_1_data);

% ʶ��ڶ������ֲ���ʾʶ����
for j=1: size(row_2, 1);
    for k=1: labelNumber
       classp(j, k) = svmclassify(model{k}, row_2_Features(j, :));
    end
    p = find(classp(j, :)==1);
    if ~isempty(p)
        labelp(j).predict=p-1;
        row_2_data(j, 1) = p(1) - 1;
    else
        row_2_data(j, 1) = -1;
    end
end
window = figure();
table_ = uitable(window, 'Data', row_2_data);