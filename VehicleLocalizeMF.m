%VehicleLocalizeMF
DiscriptorLength=Descriptor1.CellPairsNum*3;
%%%%%%%%%%%%%%%%%%Compute Database descriptors%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
VidReadObj = VideoReader(DatabaseVideoPath);
DBFramesNumber = VidReadObj.NumberOfFrames;
LDBFrontMat=zeros(DBFramesNumber,DiscriptorLength)>0;
LDBRearMat=zeros(DBFramesNumber,DiscriptorLength)>0;
LDBSide1Mat=zeros(DBFramesNumber,DiscriptorLength)>0;
LDBSide2Mat=zeros(DBFramesNumber,DiscriptorLength)>0;
disp('----------------------------------------------------------------------------');
disp('Computing database RLDB descriptors.');

tic
for i=1:DBFramesNumber
    Frame= read(VidReadObj,i);
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


%%%%%%%%%%%%%%%%%%%%%%
PropapilityVector=(1/DBFramesNumber)*ones(DBFramesNumber,1);

VidReadObj = VideoReader(RealTimeVideoPath);
Step=1;
RTNumberOfFrames=VidReadObj.NumberOfFrames;% EndImage-StartImage+1;
CurrentImage=zeros(RTNumberOfFrames,1);
CurrentLocation=zeros(RTNumberOfFrames,3);
RtDbDistanceMat=zeros(DBFramesNumber,RTNumberOfFrames,'single');
BinaryHypothesisVector=zeros(DBFramesNumber,1);
LocationConfedanceVector=zeros(RTNumberOfFrames,1);

disp('Localization phase started.');
NormalizedImpactMatrix=normr(ImpactMatrix);
tic
for ImageCounter=1:RTNumberOfFrames
    Frame= read(VidReadObj,ImageCounter);
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
    CurrentLocation(ImageCounter,:)=[MapPoints(MaxLoc,:),MapTheta(MaxLoc,1)];
    CurrentImage(ImageCounter,1)=MaxLoc;
    LocationConfedanceVector(ImageCounter,1)=MaxVal;
    PropapilityVector=Propagate(PropapilityVector,PropagationMatrix,NormalizedImpactMatrix); % Propagate
end   
ProcessingTime1=toc;
Frequncy1=RTNumberOfFrames/ProcessingTime1;

disp(strcat('Frame rate =',{' '},num2str(Frequncy1), ' Frames per second.'));
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

