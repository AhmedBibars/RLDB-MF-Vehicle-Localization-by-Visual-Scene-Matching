%VehicleLocalizeMMF
DiscriptorLength=Descriptor1.CellPairsNum*3;
%%%%%%%%%%%%%%%%%%Compute Database descriptors%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DBVidReadObj = VideoReader(DatabaseVideoPath);
DBFramesNumber = DBVidReadObj.NumberOfFrames;
LDBFrontMat=zeros(DBFramesNumber,DiscriptorLength)>0;
LDBRearMat=zeros(DBFramesNumber,DiscriptorLength)>0;
LDBSide1Mat=zeros(DBFramesNumber,DiscriptorLength)>0;
LDBSide2Mat=zeros(DBFramesNumber,DiscriptorLength)>0;
disp('----------------------------------------------------------------------------');
disp('Computing database RLDB descriptors.');

tic
for i=1:DBFramesNumber
    Frame= read(DBVidReadObj,i);
    CropedFrame=Frame(FrameCropStart:FrameCropEnd,:,:);
    LDBFrontMat(i,:)=Descriptor1.RLDB(CropedFrame(:,FrontFrameRange,:));
    LDBRearMat(i,:)=Descriptor1.RLDB(CropedFrame(:,RearFrameRange,:));
    LDBSide1Mat(i,:)=Descriptor1.RLDB(CropedFrame(:,Side1FrameRange,:));
    LDBSide2Mat(i,:)=Descriptor1.RLDB(CropedFrame(:,Side2FrameRange,:));
end
ProcessingTime=toc;
disp(strcat('Number of database frames =',{' '},num2str(DBFramesNumber),' Panoramic frames'));
disp(strcat('Database discriptors computed in',{' '},num2str(ProcessingTime), ' seconds')); 
disp(strcat('Frame rate =',{' '},num2str(DBFramesNumber/ProcessingTime), ' Panoramic frames per second')); 
disp('----------------------------------------------------------------------------');

DBDescriptorsMat=[LDBFrontMat,LDBRearMat,LDBSide1Mat,LDBSide2Mat];
clear LDBFrontMat LDBRearMat LDBSide1Mat LDBSide2Mat

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%Real-time experiment%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Start the real-time experiment.');
disp('----------------------------------------------------------------------------');

% --Searching Phase--
%%%%%%%%%%%%%%%%%%%%%%
PropapilityVector=(1/DBFramesNumber)*ones(DBFramesNumber,1);

RTVidReadObj = VideoReader(RealTimeVideoPath);
Step=1;
RTNumberOfFrames=RTVidReadObj.NumberOfFrames;% EndImage-StartImage+1;
CurrentImage=zeros(RTNumberOfFrames,1);
CurrentLocation=zeros(RTNumberOfFrames,3);
RtDbDistanceMat=zeros(DBFramesNumber,RTNumberOfFrames,'single');
BinaryHypothesisVector=zeros(DBFramesNumber,1);
LocationConfedanceVector=zeros(RTNumberOfFrames,1);

Lock=0;    %flag indicates that a precise location estimation has been reached 
ImageCounter=1;
disp('Searching phase started.');
NormalizedImpactMatrix=normr(ImpactMatrix);
tic
while Lock==0
    CurrentImageNum=ImageCounter;
    Frame= read(RTVidReadObj,CurrentImageNum);
    CropedFrame=Frame(FrameCropStart:FrameCropEnd,:,:);
    LDBFrontVect=Descriptor1.RLDB(CropedFrame(:,FrontFrameRange,:));
    LDBRearVect=Descriptor1.RLDB(CropedFrame(:,RearFrameRange,:));
    LDBSide1Vect=Descriptor1.RLDB(CropedFrame(:,Side1FrameRange,:));
    LDBSide2Vect=Descriptor1.RLDB(CropedFrame(:,Side2FrameRange,:));
    RTLDBVector=[LDBFrontVect;LDBRearVect;LDBSide1Vect;LDBSide2Vect]';
    
    MatchDiffrenceVector=LDBMatch(RTLDBVector,DBDescriptorsMat);
    MeasuredmentVect=max(MatchDiffrenceVector)-MatchDiffrenceVector;%=norm(1./(MatchDiffrenceVector-min(MatchDiffrenceVector)+1)); % Invert to transform difference into prpapility
    MeasuredmentVect=MeasuredmentVect/sum(MeasuredmentVect);          %Nomalize measurment vector to be propability
    PropapilityVector=PropapilityVector.*MeasuredmentVect;             %Update
    PropapilityVector=PropapilityVector/sum(PropapilityVector);       %Normalize
    [MaxVal,MaxLoc]=max(PropapilityVector);
    [MaxVector] = FindMaxN(PropapilityVector,2,8); %Extract the first 2 peaks, Minimium gard-distance between the extracted peaks=8 
    if MaxVector(1,1)> 2.5*MaxVector(2,1)   %max peak is 2.5 times larger than the second peak %4
        Lock=ImageCounter;
        MatchImageNum=MaxVector(1,2);
        PropapilityVector=zeros(DBFramesNumber,1);
        PropapilityVector(MatchImageNum,1)=1;
    end
    CurrentLocation(ImageCounter,:)=[MapPoints(MaxLoc,:),MapTheta(MaxLoc,1)];
    CurrentImage(ImageCounter,1)=MaxLoc;
    LocationConfedanceVector(ImageCounter,1)=MaxVal;
    ImageCounter=ImageCounter+1;
    PropapilityVector=Propagate(PropapilityVector,PropagationMatrix,NormalizedImpactMatrix); % Propagate
end   
ProcessingTime1=toc;
Frequncy1=Lock/ProcessingTime1;
disp(strcat('Searching phase has been completed in',{' '},num2str(Lock),' cycles.')); 
disp(strcat('Frame rate during searching phase =',{' '},num2str(Frequncy1), ' Frames per second.')); 
disp('----------------------------------------------------------------------------');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--Tracking phase--
%%%%%%%%%%%%%%%%%%%
disp('Tracking phase started.');
tic;
for ImageCounter=Lock+1:RTNumberOfFrames   
    MeasuredmentVect=zeros(DBFramesNumber,1);
    CurrentImageNum=ImageCounter;
    Frame= read(RTVidReadObj,CurrentImageNum);
    CropedFrame=Frame(FrameCropStart:FrameCropEnd,:,:);
    LDBFrontVect=Descriptor1.RLDB(CropedFrame(:,FrontFrameRange,:));
    LDBRearVect=Descriptor1.RLDB(CropedFrame(:,RearFrameRange,:));
    LDBSide1Vect=Descriptor1.RLDB(CropedFrame(:,Side1FrameRange,:));
    LDBSide2Vect=Descriptor1.RLDB(CropedFrame(:,Side2FrameRange,:));
    RTLDBVector=[LDBFrontVect;LDBRearVect;LDBSide1Vect;LDBSide2Vect]';
    
    [Sorted,Indexis]=sort(PropapilityVector,'descend');
    HighPropabiltyIndixes=Indexis(1:round(0.03*DBFramesNumber),1);
    SelectedDBFrames=DBDescriptorsMat(HighPropabiltyIndixes,:);
    MatchDiffrenceVector=LDBMatch(RTLDBVector,SelectedDBFrames);
    MeasuredmentVect_Temp=max(MatchDiffrenceVector)-MatchDiffrenceVector;%1./(MatchDiffrenceVector-min(MatchDiffrenceVector)+1);%4*DiscriptorLength-MatchDiffrenceVector; % Invert to transform difference into prpapility
    MeasuredmentVect(HighPropabiltyIndixes)=MeasuredmentVect_Temp;
    MeasuredmentVect=MeasuredmentVect/sum(MeasuredmentVect);          %Nomalize measurment vector to be propability
    PropapilityVector=PropapilityVector.*MeasuredmentVect;             %Update
    PropapilityVector=PropapilityVector/sum(PropapilityVector);       %Normalize
    [MaxVal,MaxLoc]=max(PropapilityVector);
    CurrentLocation(ImageCounter,:)=[MapPoints(MaxLoc,:),MapTheta(MaxLoc,1)];
    CurrentImage(ImageCounter,1)=MaxLoc;
    LocationConfedanceVector(ImageCounter,1)=MaxVal;
    [PropapilityVector]=Propagate(PropapilityVector,PropagationMatrix,NormalizedImpactMatrix); % Propagate
end
ProcessingTime2=toc;
Frequncy2=(RTNumberOfFrames-Lock)/ProcessingTime2;
disp(strcat('Frame rate during tracking phase =',{' '},num2str(Frequncy2), ' Frames per second.'));
disp('----------------------------------------------------------------------------');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Results
%%%%%%%%%%

diff_V2D=(CurrentLocation(:,1:2)-MapPoints(GT(:,1),:)).^2;
diff_V2D=sum(diff_V2D,2);
diff_V2D=sqrt(diff_V2D);
CorrectLocalization=diff_V2D<20*MapScale; 
Result2D=sum(CorrectLocalization);
Result2D=100*sum(CorrectLocalization)/(RTNumberOfFrames);
[Recall,Precision]=PrecisionRecall2(CorrectLocalization,-1*LocationConfedanceVector);
LongestGap=FindLongestGap(CorrectLocalization);
disp('Result:');
disp(strcat('Percent of filter cycles that estimate correct vehicle locations =',{' '},num2str(Result2D), ' %'));

