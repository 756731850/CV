function Features = extracthog_frame(imgFrame, Bg, imgsize, cellSize, hogFeatureSize)
    Features = zeros(size(imgFrame, 1), hogFeatureSize, 'single');
    for i = 1:size(imgFrame, 1)
        img = imcrop(Bg, imgFrame(i, :));
        %ͼ��Ӧ����һ���Ĵ�С���Ա�֤hogά��һ��
        if sum(abs(size(img)-imgsize)) ~= 0
            img = imresize(img,imgsize);%ͼ���С��һ��
        end
        Features(i, :) = extractHOGFeatures(img, 'CellSize', cellSize);
    end
end

