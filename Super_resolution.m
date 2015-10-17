% Copyright (c) 2013 - Zhaoyu Lu <zylu@g.ucla.com>
% Matlab Code

%*****************************************************************
%                       四分图片代码                            
%*****************************************************************

%************************全局变量**********************************
picRow = 160; %112;
picCol = 160; %92;
picRow_Low = 40; %36;
picCol_Low = 40;  %32; 

dowmSampling = 200;
High = 200;

person = 200; %总人数
eachperson = 5; %每个人的图片数
train = 199;  %训练集人数
eachtrain = 1; %训练集每个人的图片数
test_num = 88;

modTest = mod(test_num,eachperson);
if modTest==0
    eachtrainNum = [5];
else
    eachtrainNum = [modTest];
end

%*****************************************************************
%*****************************************************************

%********************图片读取 与 降分辨率***************************
%文件已读取，重新读取请全选，按Crtl+t取消注释【因为会花点时间】
% pic = zeros(picRow,picCol,person*eachperson);
% pic_Low = zeros(picRow_Low,picCol_Low,person*eachperson);
% Image_High = zeros(0.25*picRow*picCol,person*eachperson,4);
% Image_Low = zeros(0.25*picRow_Low*picCol_Low,person*eachperson,4);
% 
% %DowmSampling  
% route = '.\ORL_92x112\';
% if ~isdir(route)
%     warn_CannotDir = -1;
% else 
%     warn_CannotDir = 1;
% end
% direct = dir(route);
% direct(1:2,:) = []; %文件夹的前两个文件为 ‘.' 和 '..'
% 
% for i = 1:dowmSampling
%     for j = 1:eachperson 
%         name = [route direct( eachperson*(i-1)+j , 1).name ];
%         
%         %原分辨率 一个列向量代表一张图片 
%         pic(:,:,eachperson * ( i - 1 ) + j) = imresize...
%             ( imread(name), [picRow picCol] );
%         %降分辨率 一个列向量代表一张图片
%         pic_Low(:,:,eachperson * ( i - 1 ) + j) = imresize ...
%             ( imread(name),[picRow_Low picCol_Low] );
%         
%         %High
%         for ki = 1:2
%             for kj = 1:2
%             picRowK = floor(picRow/2);    %因为reshape的关系，其实floor没用
%             picColK = floor(picCol/2);
%             Image_High( 1:picRowK * picColK, ...
%                 eachperson * ( i - 1 ) + j, (ki-1)*2+kj) = ...
%             reshape( squeeze( pic( 1+(ki-1) * picRowK : ...
%                      ki * picRowK, 1+(kj-1) * picColK : ...
%                      kj * picColK,eachperson * ( i - 1 ) + j )),...
%                      picRowK * picColK,1);
%             end
%         end
% 
%         %Low 
%         for ki = 1:2
%             for kj = 1:2
%             picRowK_Low = floor(picRow_Low/2);
%             picColK_Low = floor(picCol_Low/2);
%             Image_Low( 1:picRowK_Low * picColK_Low, ...
%                         eachperson * ( i - 1 ) + j, (ki-1)*2+kj)  =  ...
%             reshape( squeeze( pic_Low(1+(ki-1) * picRowK_Low : ...
%                      ki * picRowK_Low, 1+(kj-1) * picColK_Low : ...
%                      kj * picColK_Low,eachperson * ( i - 1 ) + j )),...
%                      picRowK_Low * picColK_Low,1) ;
%             end
%         end
%         
%     end
% end
%*****************************************************************
%*****************************************************************
% 
% %****************提取训练集 和 测试集 (可取任意人的任意N张)***********
Train_Num = zeros(1,person * eachtrain);
for i = 1:person  
    for j = 1:eachtrain
        Train_Num( eachtrain*(i-1) + j) = eachperson*(i-1) + eachtrainNum(j);
    end
end
Train_Num( :,(ceil(test_num/eachperson)*eachtrain-eachtrain+1):(ceil(test_num/eachperson)*eachtrain) ) = [];

Image_Low_Train  = Image_Low(:,Train_Num,1:4);
Image_High_Train = Image_High(:,Train_Num,1:4);
Image_Low_Test = squeeze( Image_Low(:,test_num,1:4) );
%*****************************************************************
%*****************************************************************

%************************显示低、高分标率原图**********************
%显示低分标率原图
Show_Image_Low_Test = ...
    [ reshape( squeeze( Image_Low_Test(:,1) ),picRowK_Low,picColK_Low), ...
      reshape( squeeze( Image_Low_Test(:,2) ), ...
      picRowK_Low,picColK_Low); reshape( squeeze( Image_Low_Test(:,3) ), ...
      picRowK_Low,picColK_Low), ...
      reshape( squeeze( Image_Low_Test(:,4) ),picRowK_Low,picColK_Low) ];
subplot(2,4,1);
imshow(Show_Image_Low_Test,[0,255])
%显示高分标率原图
subplot(2,4,5);
imshow(pic(:,:,test_num),[0,255]);
%*****************************************************************
%*****************************************************************

% %***********论文方法实现步骤一：计算低分辨率线性组合参数c ***********
rl = zeros(picRowK*picColK,1,4);
rl2 = zeros(picRowK*picColK,1,4);
rl3 = zeros(picRowK,picColK,4);
rl4 = zeros(picRowK,picColK,4);
for part = 1:4
    meanImage_Low = mean(Image_Low_Train(:,:,part),2);  
    Image_L = zeros(picRowK_Low * picColK_Low,train*eachtrain);
    for i = 1:(train*eachtrain)
        Image_L(:,i) = Image_Low_Train(:,i,part) - meanImage_Low;
    end

    meanImage_High = mean(Image_High_Train(:,:,part),2);
    Image_H = zeros(picRowK*picColK,train*eachtrain);
    for i = 1:(train*eachtrain)
        Image_H(:,i) = Image_High_Train(:,i,part) - meanImage_High;
    end

    %计算低分辨率训练图像集的PCA
    R = Image_L'*Image_L;
    [Vl,Al] = eig(R);

    
    
    %线性组合出待超分辨率图像
    El = Image_L * Vl * Al^(-0.5);
    xl = Image_Low_Test(:,part);    
    wl =  El' * ( xl - meanImage_Low) ;
    
    cl = Vl * Al^(-0.5) * wl;
    rl(:,:,part) = Image_H * cl + meanImage_High;
    
    count = 0; %统计改变的权重值个数
    for iw = 1 : (train * eachtrain)
        if abs(wl(iw)) > 0.22  *  sqrt( abs(Al(iw,iw)) ) 
            %0.2开始界线比较明显，但是滤波效果明显
            count = count+1;
             wl(iw) =  0 * sqrt( abs(Al(iw,iw)) ); 
         end    
    end
    
    cl = Vl * Al^(-0.5) * wl;
    rl2(:,:,part) = Image_H * cl + meanImage_High;
    
    rl3(:,:,part) = reshape( abs(rl2(:,:,part)),picRowK,picColK);
    range = 10;
    countSimilar = 0;
    for S_i = 2:(picRowK-1)
        for S_j = 2:(picColK-1)
            meanPix = (sum(sum(rl3( (S_i-1):(S_i+1),(S_j-1):(S_j+1),part)))...
                      - rl3(S_i,S_j,part))/8;
            for S_Single_i = (S_i-1):(S_i+1)
                for S_Single_j = (S_j-1):(S_j+1)
                    if S_Single_i==S_i && S_Single_j==S_j
                        continue
                    end
                    if abs( rl3(S_Single_i,S_Single_j,part) - meanPix)...
                       <=range
                       countSimilar = countSimilar+1;
                    end
                end
            end
            
            if countSimilar>=6
                rl3(S_i,S_j,part) = meanPix;
            end
            countSimilar = 0;
        end
    end
    
%     %提高对比度
%     for Con_i = 1:picRowK
%         for Con_j = 1:picColK
%             if rl3(Con_i,Con_j,part)>150
%                 rl4(Con_i,Con_j,part) = rl3(Con_i,Con_j,part) + 10;
%             else if rl3(Con_i,Con_j,part) < 100
%                      rl4(Con_i,Con_j,part) = rl3(Con_i,Con_j,part) - 10;
%                 else
%                      rl4(Con_i,Con_j,part) = rl3(Con_i,Con_j,part);
%                 end
%             end
%         end
%     end
    
end




%图像复原reshape 并显示
showImage_L = ...
    [ reshape( abs(rl(:,:,1)),picRowK,picColK),...
      reshape( abs(rl(:,:,2)),picRowK,picColK); reshape( abs(rl(:,:,3)),picRowK,picColK),...
      reshape( abs(rl(:,:,4)),picRowK,picColK)];
subplot(2,4,2);
imshow(showImage_L,[0,255])

showImage_L2 = ...
    [ reshape( abs(rl2(:,:,1)),picRowK,picColK),...
      reshape( abs(rl2(:,:,2)),picRowK,picColK); reshape( abs(rl2(:,:,3)),picRowK,picColK),...
      reshape( abs(rl2(:,:,4)),picRowK,picColK)];
subplot(2,4,3);
imshow(showImage_L2,[0,255])

showImage_L3 = ...
      [  rl3(:,:,1),rl3(:,:,2) ; rl3(:,:,3),rl3(:,:,4)];
%     [ reshape( abs(rl3(:,:,1)),56,46),...
%       reshape( abs(rl3(:,:,2)),56,46); reshape( abs(rl3(:,:,3)),56,46),...
%       reshape( abs(rl3(:,:,4)),56,46)];
subplot(2,4,4);
imshow(showImage_L3,[0,255])

showImage_L4 = ...
      [  rl4(:,:,1),rl4(:,:,2) ; rl4(:,:,3),rl4(:,:,4)];
%     [ reshape( abs(rl3(:,:,1)),56,46),...
%       reshape( abs(rl3(:,:,2)),56,46); reshape( abs(rl3(:,:,3)),56,46),...
%       reshape( abs(rl3(:,:,4)),56,46)];
subplot(2,4,7);
imshow(showImage_L4,[0,255])



%***********论文方法实现步骤二：计算高分辨率线性组合参数c ***********
%高分辨率线性组合
rh = zeros(picRowK*picColK,1,4);
rh2 = zeros(picRowK*picColK,1,4);
rh3 = zeros(picRowK,picColK,4);
for part = 1:4
    
    meanImage_High = mean(Image_High_Train(:,:,part),2);
    Image_H = zeros(picRowK*picColK,train*eachtrain);
    for i = 1:(train*eachtrain)
        Image_H(:,i) = Image_High_Train(:,i,part) - meanImage_High;
    end
    
    R = Image_H'*Image_H;
    [Vh,Ah] = eig(R);

    Eh = Image_H * Vh * Ah^(-0.5);
    xh = rl(:,:,part);    % squeeze( Image_Low_Train(:,1) );

    wh = Eh' * ( xh - meanImage_High);
    ch = Vh * Ah^(-0.5) * wh;
    rh(:,:,part) = Image_H * ch + meanImage_High;
    
    %****************************************************    
    %加约束后 comparation
    %加入特征值分权重处理
    %加入提高对比度处理
    wh = Eh' * ( xh - meanImage_High);

    count = 0; %统计改变的权重值个数
    count2 = 0;
    awh = 2; %1.1还不错
    for i = 1 : (train * eachtrain)
        if abs(wh(i)) > 0.18 *  sqrt( abs(Ah(i,i)) ) 
            %0.15把噪声几乎消除
            count = count+1;
            %wh(i) = wh(i) * 0.0004 *  sqrt( abs(Ah(i,i)) );
            wh(i) =  0 * sqrt( abs(Ah(i,i)) );
        else if abs(wh(i)) > 0.13 *  sqrt( abs(Ah(i,i)) ) 
            count2 = count2+1;
            %wh(i) = wh(i) * 0.0004 *  sqrt( abs(Ah(i,i)) );
            %wh(i) =  0.2 * sqrt( abs(Ah(i,i)) );
            %wh(i) = 1.5 * wh(i);
            else 
             %   wh(i) =  awh * wh(i) + 0.001 * sqrt( abs(Ah(i,i)) ) ;
                %wh(i) =  awh * wh(i);
            end
        end     
    end    

    ch = Vh * Ah^(-0.5) * wh;
    rh2(:,:,part) = Image_H * ch + meanImage_High;

    rh3(:,:,part) = reshape( abs(rh2(:,:,part)),picRowK,picColK);
    %高通滤波
    range = 10;
    countSimilar = 0;
    for S_i = 2:(picRowK-1)
        for S_j = 2:(picColK-1)
            meanPix = (sum(sum(rh3( (S_i-1):(S_i+1),(S_j-1):(S_j+1),part)))...
                      - rh3(S_i,S_j,part))/8;
            for S_Single_i = (S_i-1):(S_i+1)
                for S_Single_j = (S_j-1):(S_j+1)
                    if S_Single_i==S_i && S_Single_j==S_j
                        continue
                    end
                    if abs( rh3(S_Single_i,S_Single_j,part) - meanPix)...
                       <=range
                       countSimilar = countSimilar+1;
                    end
                end
            end
            
            if countSimilar>=6
                rh3(S_i,S_j,part) = meanPix;
            end
            countSimilar = 0;
        end
    end
    
    
end
%********************************************
    
%图像复原reshape 并显示
showImage_H = ...
    [ reshape( abs(rh(:,:,1)),picRowK,picColK),...
      reshape( abs(rh(:,:,2)),picRowK,picColK); reshape( abs(rh(:,:,3)),picRowK,picColK),...
      reshape( abs(rh(:,:,4)),picRowK,picColK)];
subplot(2,4,6);
imshow(showImage_H,[0,255])

showImage_H2 = ...
    [ reshape( abs(rh2(:,:,1)),picRowK,picColK),...
      reshape( abs(rh2(:,:,2)),picRowK,picColK); reshape( abs(rh2(:,:,3)),picRowK,picColK),...
      reshape( abs(rh2(:,:,4)),picRowK,picColK)];
subplot(2,4,7);
imshow(showImage_H2,[0,255])

showImage_L3 = ...
      [  rh3(:,:,1),rh3(:,:,2) ; rh3(:,:,3),rh3(:,:,4)];
subplot(2,4,8);
imshow(showImage_L3,[0,255])
%*****************************************************************
%*****************************************************************
