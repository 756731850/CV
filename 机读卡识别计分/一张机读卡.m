
close all;
clc;

I = imread('./img/����ͼƬ/ƻ��6s-P1 (1).jpg');
I = imresize(I, [640, 360]);    % ͼ���С�޸ģ���ֹ�ֱ��ʹ���ʹ����ʱ��̫��
[M, N, pass] = size(I);
if pass > 1 % �ж��Ƿ��ǻҶ�ͼ��
    I = rgb2gray(I); % �Ҷ�ת�� 
end
%I = histeq(I); % ͼ����ǿ�������ֻ�����������Ӱ��
figure();
subplot(131);
imshow(I);title('ԭͼ');
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

Binary = BinaryImage;
ROI = imcrop(Binary, roi_pos);
ROI_edge = edge(ROI, 'canny');
[H_, T_, R_] = hough(ROI_edge);
P_ = houghpeaks(H_, 5);
lines = houghlines(ROI_edge, T_, R_, P_, 'FillGap', 5, 'MinLength', 30);
% ��ʾROI hough����ȡ���
subplot(143); imshow(ROI); title('��ROI houghֱ����ȡ���'); hold on;
max_len = 0;
for k = 1:length(lines)
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
    for j=i+1:length(lines)
        a = lines(i).point1; b = lines(i).point2;
        c = lines(j).point1; d = lines(j).point2;
        %�����ĸΪ0 ��ƽ�л���, ���ཻ 
        denominator = (b(2) - a(2))*(d(1) - c(1)) - (a(1) - b(1))*(c(2) - d(2));
        if denominator==0
            continue;
        end
        x = ((b(1) - a(1)) * (d(1) - c(1)) * (c(2) - a(2))...
                + (b(2) - a(2)) * (d(1) - c(1)) * a(1)...
                - (d(2) - c(2)) * (b(1) - a(1)) * c(1) ) / denominator;
        y = -( (b(2) - a(2)) * (d(2) - c(2)) * (c(1) - a(1))...
                + (b(1) - a(1)) * (d(2) - c(2)) * a(2)...
                - (d(1) - c(1)) * (b(2) - a(2)) * c(2) ) / denominator;
        
        % ʡ�Գ����߽�ĵ�
        if x > size(ROI, 2) || x <= 0 || y > size(ROI, 1) || y <= 0
            continue
        end
        
        cross_point(ic, 1) = x; cross_point(ic, 2) = y;
        ic = ic + 1;
    end
end
cross_point(ic:500 , :) = []; % ɾ�����������ж����Ԫ��
subplot(144); imshow(ROI); title('hough��ȡֱ�ߵĽ���'); hold on;
plot(centerP(1), centerP(2), 'o');
for i=1:ic-1
    plot(cross_point(i,1), cross_point(i, 2), 'x');
end

% Ѱ�����ĵ�
centerP = mean(cross_point);
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


% % Ѱ�ұ�Ե�ĸ�����(�ҵķ���)
% figure(); imshow(ROI); hold on;
% plot(tp_point);
% hold off;
% roi_pos = uint16(condi_roi(index_k).BoundingBox);
% roi_mpt = zeros(size(ROI));
% for i = 1:roi_pos(3)
%     for j = 1:10
%         roi_mpt(j, i) = 1;
%     end
% end
% for i = 1:roi_pos(3)
%     for j = -10:0
%         roi_mpt(roi_pos(4) + j, i) = 1;
%     end
% end
% for i = 1:roi_pos(4)
%     for j = 1:10
%         roi_mpt(i, j) = 1;
%     end
% end
% for i = 1:roi_pos(4)
%     for j = -10:0
%         roi_mpt(i, roi_pos(3) + j) = 1;
%     end
% end
% %figure();imshow(roi_mpt);
% 
% centerX = (roi_pos(1) + roi_pos(3))/2; % ���ĵ��x����
% centerY = (roi_pos(2) + roi_pos(4))/2; % ���ĵ��y����
% vis = zeros(1, M, 'uint16');     % ��������¼
% for i=1:length(tp_point)
%     temp_pos = uint16(tp_point(i).Location);
%     if roi_mpt(temp_pos(2), temp_pos(1)) == 0
%         continue;
%     end
%     if temp_pos(1) < centerX && temp_pos(2) < centerY
%         if abs(temp_pos(1) - roi_pos(1)) < abs(temp_pos(2) - roi_pos(2))    % y��仯��k
%             k = abs(temp_pos(2) - roi_pos(2));
%         else 
%             k = abs(temp_pos(1) - roi_pos(1));
%         end
%     elseif temp_pos(1) > centerX && temp_pos(2) < centerY
%         if abs(temp_pos(1) - roi_pos(1) - roi_pos(3)) < abs(temp_pos(2) - roi_pos(2))
%             k = abs(temp_pos(2) - roi_pos(2));
%         else 
%             k = abs(temp_pos(1) - roi_pos(1) - roi_pos(3));
%         end
% 
%     elseif temp_pos(1) < centerX && temp_pos(2) > centerY
%         if abs(temp_pos(1) - roi_pos(1)) < abs(temp_pos(2) - roi_pos(2) - roi_pos(4))
%             k = abs(temp_pos(2) - roi_pos(2) - roi_pos(4));
%         else 
%             k = abs(temp_pos(1) - roi_pos(1));
%         end
%     elseif temp_pos(1) > centerX && temp_pos(2) > centerY
%         if abs(temp_pos(1) - roi_pos(1) - roi_pos(3)) < abs(temp_pos(2) - roi_pos(2) - roi_pos(4))
%             k = abs(temp_pos(2) - roi_pos(2) - roi_pos(4));
%         else 
%             k = abs(temp_pos(1) - roi_pos(1) - roi_pos(3));
%         end
%     end
%     if k == 0
%         continue;
%     end
%     vis(k) = vis(k) + 1;
%     if vis(k) >= 2
%         if temp_pos(1) < centerX && temp_pos(2) < centerY
%             if abs(temp_pos(1) - roi_pos(1)) < abs(temp_pos(2) - roi_pos(2))    % y��仯��k
%                 swi = 1;
%             else 
%                 swi = 0;
%             end
%         elseif temp_pos(1) > centerX && temp_pos(2) < centerY
%             if abs(temp_pos(1) - roi_pos(1) - roi_pos(3)) < abs(temp_pos(2) - roi_pos(2))
%                 swi = 0;
%             else
%                 swi = 1;
%             end
%         elseif temp_pos(1) < centerX && temp_pos(2) > centerY
%             if abs(temp_pos(1) - roi_pos(1)) < abs(temp_pos(2) - roi_pos(2) - roi_pos(4))
%                 swi = 0;
%             else 
%                 swi = 1;
%             end
%         elseif temp_pos(1) > centerX && temp_pos(2) > centerY
%            	if abs(temp_pos(1) - roi_pos(1) - roi_pos(3)) < abs(temp_pos(2) - roi_pos(2) - roi_pos(4))
%                 swi = 1;
%             else 
%                 swi = 0;
%             end
%         end
%         if swi == 1
%             dot(1, 1) = roi_pos(1) + k;                 dot(1, 2) = roi_pos(2);
%             dot(2, 1) = roi_pos(1) + roi_pos(3);        dot(2, 2) = roi_pos(2) + k;
%             dot(3, 1) = roi_pos(1);                     dot(3, 2) = roi_pos(2) + roi_pos(4) - k;
%             dot(4, 1) = roi_pos(1) + roi_pos(3) - k;    dot(4, 2) = roi_pos(2) + roi_pos(4);
%         else
%             dot(1, 1) = roi_pos(1);                     dot(1, 2) = roi_pos(2) + k;
%             dot(2, 1) = roi_pos(1) + roi_pos(3) - k;    dot(2, 2) = roi_pos(2);
%             dot(3, 1) = roi_pos(1) + k;                 dot(3, 2) = roi_pos(2) + roi_pos(4);
%             dot(4, 1) = roi_pos(1) + roi_pos(3);        dot(4, 2) = roi_pos(2) + roi_pos(4) - k;
%         end
%         break;
%     end
% end

%% ͼ��У��
fixPoints = [roi_pos(1), roi_pos(2); roi_pos(1) + roi_pos(3), roi_pos(2);...
    roi_pos(1), roi_pos(2) + roi_pos(4); roi_pos(1) + roi_pos(3), roi_pos(2) + roi_pos(4)];
tfrom = fitgeotrans(dot, fixPoints, 'projective');
corrected_img = imwarp(I, tfrom);
subplot(122); imshow(corrected_img); title('ͼ��У��');

%% ѡ����ʶ��


