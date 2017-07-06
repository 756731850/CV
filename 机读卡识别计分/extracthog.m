function Features = extracthog(imgSet,numImages,imgsize,cellSize,hogFeatureSize)
    Features = zeros(numImages, hogFeatureSize, 'single');
    for i = 1:numImages
        img = readImage(imgSet, i);
        %ͼ��Ӧ����һ���Ĵ�С���Ա�֤hogά��һ��
        if sum(abs(size(img)-imgsize)) ~= 0
            img = imresize(img,imgsize);%ͼ���С��һ��
        end
        % Apply pre-processing steps
       % img = im2bw(img,graythresh(img));
        Features(i, :) = extractHOGFeatures(img, 'CellSize', cellSize);
      %  subplot(2,5,i);imshow(img)
    end
end