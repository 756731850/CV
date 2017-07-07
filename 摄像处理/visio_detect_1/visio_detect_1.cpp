// visio_detect_1.cpp : �������̨Ӧ�ó������ڵ㡣
//

#include "stdafx.h"
#include <iostream>
#include <string>
#include <opencv2/opencv.hpp>
using namespace std;
using namespace cv;

int main()
{
	VideoCapture cam;	// ����ͷ����
	VideoWriter vwriter;	
	cam.open(0);		// ������ͷ
	double w = cam.get(CV_CAP_PROP_FRAME_WIDTH);
	double h = cam.get(CV_CAP_PROP_FRAME_HEIGHT);
	vwriter.open("../test.avi", CV_FOURCC('P', 'I', 'M', '1'), 25, Size(w, h));		//CV_FOURCC�Լ����ֲ�
	if (!cam.isOpened() || !vwriter.isOpened()) {
		cout << "��ʧ��" << endl;	
		return 0;
	}
	Mat frame;					// ��������ͷ��׽����ͼ��
	Mat tmpImg;
	bool bStop = false;			// ����
	while(!bStop) {
		cam >> frame;			// ����׽����ͼ�񱣴浽frame��
		cvtColor(frame, tmpImg, CV_RGB2GRAY);					// �Ҷ�ת��
		GaussianBlur(tmpImg, tmpImg, Size(11, 11), 10);		// ��˹ģ��
		//threshold(tmpImg, tmpImg, 100, 255, CV_THRESH_BINARY);
		Canny(tmpImg, tmpImg, 0, 60);							// ��Ե���
		imshow("Gary Camera", tmpImg);							// ��ʾ
		vwriter << frame;
		//imshow("Camera Frame", frame);
		int key = waitKey(40);
		if (key >= 0) {		// ���̼������ʱ���˳�����ͷ
			bStop = true;		
		}
	}

	vwriter.release();
	if (cam.isOpened())	
		cam.release();
    return 0;
}

