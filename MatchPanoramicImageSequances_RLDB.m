DiscriptorLength=Descriptor1.CellPairsNum*3;
%%%%%%%%%%%%%%%%%%Compute Database descriptors%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
VidReadObj = VideoReader(DatabaseVideoPath);
DBFramesNumber = VidReadObj.NumberOfFrames;
LDBFrontMat=zeros(DBFramesNumber,DiscriptorLength);
LDBRearMat=zeros(DBFramesNumber,DiscriptorLength);
LDBSide1Mat=zeros(DBFramesNumber,DiscriptorLength);
LDBSide2Mat=zeros(DBFramesNumber,DiscriptorLength);
disp('----------------------------------------------------------------------------');
disp('Computing database RLDB descriptors.');

tic
for i=1:DBFramesNumber
    Frame= read(VidReadObj,i);
    CropedFrame=Frame(FrameCropStart:FrameCropEnd,:,:);
    LDBFrontMat(i,:)=Descriptor1.RLDB(CropedFrame(:,1:512,:));
    LDBRearMat(i,:)=Descriptor1.RLDB(CropedFrame(:,513:1024,:));
    LDBSide1Mat(i,:)=Descriptor1.RLDB(CropedFrame(:,1025:1536,:));
    LDBSide2Mat(i,:)=Descriptor1.RLDB(CropedFrame(:,1537:2048,:));
end
ProcessingTime=toc;
disp(strcat('Number of database frames =',{' '},num2str(DBFramesNumber),' Panoramic frames'));
disp(strcat('Database discriptors computed in',{' '},num2str(ProcessingTime), ' seconds')); 
disp(strcat('Frame rate =',{' '},num2str(DBFramesNumber/ProcessingTime), ' Panoramic frames per second')); 
disp('----------------------------------------------------------------------------');

LDBFrontMat=LDBFrontMat>0;
LDBRearMat=LDBRearMat>0;
LDBSide1Mat=LDBSide1Mat>0;
LDBSide2Mat=LDBSide2Mat>0;
DBDescriptorsMat=[LDBFrontMat,LDBRearMat,LDBSide1Mat,LDBSide2Mat];
clear LDBFrontMat LDBRearMat LDBSide1Mat LDBSide2Mat

%%%%%%%%%%%%%%%%%%%Compute Quaries frames descriptors%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
VidReadObj = VideoReader(QueryVideoPath);
QuaryFramesNumber = VidReadObj.NumberOfFrames;
RtLDBFrontMat=zeros(QuaryFramesNumber,DiscriptorLength);
RtLDBRearMat=zeros(QuaryFramesNumber,DiscriptorLength);
RtLDBSide1Mat=zeros(QuaryFramesNumber,DiscriptorLength);
RtLDBSide2Mat=zeros(QuaryFramesNumber,DiscriptorLength);
disp('Computing Quary frames RLDB descriptors.');
tic
for i=1:QuaryFramesNumber
    Frame= read(VidReadObj,i);
    CropedFrame=Frame(FrameCropStart:FrameCropEnd,:,:);
    RtLDBFrontMat(i,:)=Descriptor1.RLDB(CropedFrame(:,1:512,:));
    RtLDBRearMat(i,:)=Descriptor1.RLDB(CropedFrame(:,513:1024,:));
    RtLDBSide1Mat(i,:)=Descriptor1.RLDB(CropedFrame(:,1025:1536,:));
    RtLDBSide2Mat(i,:)=Descriptor1.RLDB(CropedFrame(:,1537:2048,:));
end
ProcessingTime=toc;
disp(strcat('Number of quary frames =',{' '},num2str(QuaryFramesNumber),' Panoramic frames'));
disp(strcat('Quary frames RLDB discriptors computed in',{' '},num2str(ProcessingTime), ' seconds')); 
disp(strcat('Frame rate =',{' '},num2str(QuaryFramesNumber/ProcessingTime), ' Panoramic Frames per second')); 
disp('----------------------------------------------------------------------------');

RtLDBFrontMat=RtLDBFrontMat>0;
RtLDBRearMat=RtLDBRearMat>0;
RtLDBSide1Mat=RtLDBSide1Mat>0;
RtLDBSide2Mat=RtLDBSide2Mat>0;
QuaryDescriptorsMat=[RtLDBFrontMat,RtLDBRearMat,RtLDBSide1Mat,RtLDBSide2Mat];
clear RtLDBFrontMat RtLDBRearMat RtLDBSide1Mat RtLDBSide2Mat

%%%%%%%%%%%%%%%%%%%%%%%%%%Matching%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DistanceMatrix=zeros(DBFramesNumber,QuaryFramesNumber,'single'); % Distance matrix
MatchDiff=zeros(QuaryFramesNumber,1,'single');
CurrentImage=zeros(QuaryFramesNumber,1,'single');
CurrentLocation=zeros(QuaryFramesNumber,3);
disp('Finding best database-match for each quary frame.');
tic
for i=1:QuaryFramesNumber
    DistanceMatrix(:,i)=LDBMatch(QuaryDescriptorsMat(i,:),DBDescriptorsMat); % Compute Hamming distance between query(i) and each discriptor in the database
    [minval,minLoc]=min(DistanceMatrix(:,i));
    MatchDiff(i,1)=minval; % Hamming distance between quary(i) and its best database-match. 
    CurrentImage(i,1)=minLoc; % best database-match
    CurrentLocation(i,:)=[MapPoints(minLoc,:),MapTheta(minLoc,1)];
    %i
end
ProcessingTime=toc;
disp(strcat('Avarage processing time of finding database match for a query frame =',{' '},num2str(ProcessingTime/QuaryFramesNumber),' sec.'));
display(strcat('Matching Rate =',{' '},num2str(QuaryFramesNumber/ProcessingTime),' Query frames per second'));
disp('----------------------------------------------------------------------------');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Compute matching accuricy%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
diff_V=abs(CurrentImage-GT(:,1));
CorrectLocalization=diff_V<21;
Result=sum(CorrectLocalization);
disp(strcat('Result:',{' '},num2str(Result),' correctly matched frames'));
Result=100*sum(CorrectLocalization)/(QuaryFramesNumber);
disp(strcat('Percent of correctly matched quary frames =',{' '}, num2str(Result), ' %'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Precision-Recall%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Recall,Precision]=PrecisionRecall(GT(:,1),CurrentImage,MatchDiff);





diff_V2D=(CurrentLocation(:,1:2)-MapPoints(GT(:,1),:)).^2;
diff_V2D=sum(diff_V2D,2);
diff_V2D=sqrt(diff_V2D);
CorrectLocalization=diff_V2D<20;
LongestGap=FindLongestGap(CorrectLocalization);
Result2D=sum(CorrectLocalization);
Result2D=100*sum(CorrectLocalization)/(QuaryFramesNumber);