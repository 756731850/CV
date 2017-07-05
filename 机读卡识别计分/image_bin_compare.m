
close all;
clc;

I = imread('./img/����ͼƬ/����-P2 (3).jpg');
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

h_point = detectHarrisFeatures(Binary); % Harris�ǵ���

condi_roi = regionprops(im2bw(1.0 - Binary), 'area', 'boundingbox'); % ��roi
max_area = 0;
index_k = 0;
figure(); subplot(131); imshow(Binary); title('��ֵ��');
subplot(132); imshow(Binary); title('ROI��ǵ���'); hold on;
for i=1:length(condi_roi)
    area = condi_roi(i).Area;
    if area > max_area
        max_area = area;
        index_k = i;
    end
end
rectangle('position', condi_roi(index_k).BoundingBox, 'EdgeColor', 'r', 'lineWidth', 1);  

plot(h_point);
hold off;

ROI = imcrop(Binary, condi_roi(index_k).BoundingBox);
tp_point = detectHarrisFeatures(ROI);
% figure(); imshow(ROI); hold on;
% plot(tp_point);
% hold off;

% % Ѱ�ұ�Ե�ĸ�����(�ҵķ���)
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
%dot = ginput(4);
dot = double(dot);
roi_pos = double(roi_pos);
w=round(sqrt((dot(1,1)-dot(2,1))^2+(dot(1,2)-dot(2,2))^2));     %��ԭ�ı��λ���¾��ο�
h=round(sqrt((dot(1,1)-dot(3,1))^2+(dot(1,2)-dot(3,2))^2));     %��ԭ�ı��λ���¾��θ�
w = roi_pos(3);
h = roi_pos(4);

y=[dot(1,1) dot(2,1) dot(3,1) dot(4,1)];        %�ĸ�ԭ����
x=[dot(1,2) dot(2,2) dot(3,2) dot(4,2)];

%�������µĶ��㣬��ȡ�ľ���,Ҳ����������������״
%�����ԭͼ���Ǿ��Σ���ͼ���Ǵ�dot��ȡ�õĵ���ɵ������ı���.:)
Y=[dot(1,1) dot(1,1) dot(1,1)+h dot(1,1)+h];     
X=[dot(1,2) dot(1,2)+w dot(1,2) dot(1,2)+w];
Y = [roi_pos(1), roi_pos(1), roi_pos(1) + h, roi_pos(1) + h];
X = [roi_pos(2), roi_pos(2) + w, roi_pos(2), roi_pos(2) + w];

B=[X(1) Y(1) X(2) Y(2) X(3) Y(3) X(4) Y(4)]';   %�任����ĸ����㣬�����ұߵ�ֵ
%�����ⷽ���飬���̵�ϵ��
A=[x(1) y(1) 1 0 0 0 -X(1)*x(1) -X(1)*y(1);             
   0 0 0 x(1) y(1) 1 -Y(1)*x(1) -Y(1)*y(1);
   x(2) y(2) 1 0 0 0 -X(2)*x(2) -X(2)*y(2);
   0 0 0 x(2) y(2) 1 -Y(2)*x(2) -Y(2)*y(2);
   x(3) y(3) 1 0 0 0 -X(3)*x(3) -X(3)*y(3);
   0 0 0 x(3) y(3) 1 -Y(3)*x(3) -Y(3)*y(3);
   x(4) y(4) 1 0 0 0 -X(4)*x(4) -X(4)*y(4);
   0 0 0 x(4) y(4) 1 -Y(4)*x(4) -Y(4)*y(4)];

fa=A\B;        %���ĵ���õķ��̵Ľ⣬Ҳ��ȫ�ֱ任ϵ��
a=fa(1);b=fa(2);c=fa(3);
d=fa(4);e=fa(5);f=fa(6);
g=fa(7);h=fa(8);

rot=[d e f;
     a b c;
     g h 1];        %��ʽ�е�һ������x,Matlab��һ����ʾy�������Ҿ���1,2�л�����

pix1=rot*[1 1 1]'/(g*1+h*1+1);  %�任��ͼ�����ϵ�
pix2=rot*[1 N 1]'/(g*1+h*N+1);  %�任��ͼ�����ϵ�
pix3=rot*[M 1 1]'/(g*M+h*1+1);  %�任��ͼ�����µ�
pix4=rot*[M N 1]'/(g*M+h*N+1);  %�任��ͼ�����µ�

height=round(max([pix1(1) pix2(1) pix3(1) pix4(1)])-min([pix1(1) pix2(1) pix3(1) pix4(1)]));     %�任��ͼ��ĸ߶�
width=round(max([pix1(2) pix2(2) pix3(2) pix4(2)])-min([pix1(2) pix2(2) pix3(2) pix4(2)]));      %�任��ͼ��Ŀ��
imgn=zeros(height,width);

delta_y=round(abs(min([pix1(1) pix2(1) pix3(1) pix4(1)])));            %ȡ��y����ĸ��ᳬ����ƫ����
delta_x=round(abs(min([pix1(2) pix2(2) pix3(2) pix4(2)])));            %ȡ��x����ĸ��ᳬ����ƫ����
inv_rot=inv(rot);

for i = 1-delta_y:height-delta_y                        %�ӱ任ͼ���з���Ѱ��ԭͼ��ĵ㣬������ֿն�������ת�Ŵ�ԭ��һ��
    for j = 1-delta_x:width-delta_x
        pix=inv_rot*[i j 1]';       %��ԭͼ�������꣬��Ϊ[YW XW W]=fa*[y x 1],�������������[YW XW W],W=gy+hx+1;
        pix=inv([g*pix(1)-1 h*pix(1);g*pix(2) h*pix(2)-1])*[-pix(1) -pix(2)]'; %�൱�ڽ�[pix(1)*(gy+hx+1) pix(2)*(gy+hx+1)]=[y x],����һ�����̣���y��x�����pix=[y x];
        
        if pix(1)>=0.5 && pix(2)>=0.5 && pix(1)<=M && pix(2)<=N
            imgn(i+delta_y,j+delta_x)=I(round(pix(1)),round(pix(2)));     %���ڽ���ֵ,Ҳ������˫���Ի�˫������ֵ
        end  
    end
end

subplot(133); imshow(uint8(imgn)); title('ͼ��У��');

%figure(); imshow(Binary); hold on;
% rectangle('Position', [dot(1, 1), dot(1, 2), dot(2, 1)-dot(1,1), dot(3,2)-dot(1,2)], 'EdgeColor', 'r', 'lineWidth', 1);
% hold off;