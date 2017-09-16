%function pretraindata
filepath0 = 'digittest/trainsets/'; % ��ȡѵ����Ŀ¼
filepaths=dir(filepath0);
for i=3:size(filepaths,1) % ��0��9����Ŀ¼
    filenames=dir([filepath0 filepaths(i).name '/']); % �򿪵�ǰ���ֵ�ѵ����Ŀ¼
    % ����ѵ����
    cnt = 0;
    for j=3:size(filenames,1)
        img=imread([filepath0 filepaths(i).name '/'  filenames(j).name]);
        if size(img, 3) > 1
            img=rgb2gray(img);
        end
        img=imresize(img,[163,96]);
        imwrite(img,[filepath0 filepaths(i).name '/'  filepaths(i).name '-' num2str(cnt) '.bmp'])
        outputView = imref2d(size(img));
        for cnt=1:100
            tform=zeros(3);
            tform(1:2,1:2)=eye(2)-rand(2)/10;
            tform(3,3)=1;
            T= affine2d(tform);
            I= imwarp(img,T, 'OutputView', outputView);
            imwrite(I,[filepath0 filepaths(i).name '/'  filepaths(i).name '-' num2str(cnt) '.bmp'])
        end
     end
 end
