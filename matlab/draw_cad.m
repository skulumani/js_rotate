% 11 September 2015
% script to test and animate motion
close all

% load model
load('TacSAT.mat');

% Scale model to fit appropriately
TV = 1/300*[TV(:,1) TV(:,2) TV(:,3)]*ROT2(pi/2)';
boresight = [1, 0, 0];
% set up the figure window
figure('color','w','units','normalized','outerposition',[0 0 1 1])
hold all

% radius of cone at unit length
[sph.x, sph.y, sph.z]=sphere(100);
h_sph=surf(sph.x,sph.y,sph.z);

% set some rendering options
set(h_sph,'LineStyle','none','FaceColor',0.8*[1 1 1],...
    'FaceLighting','gouraud','AmbientStrength',0.5,...
    'Facealpha',0.3,'Facecolor',[0.8 0.8 0.8]);

light('Position',[0 0 100],'Style','infinite');
material dull;
axis equal;
axis off
xlabel('x')
ylabel('y')
zlabel('z')

tcs = patch('faces', TF, 'vertices', TV);
set(tcs, 'facec', 'flat');            % Set the face color flat
set(tcs, 'FaceVertexCData', TC);       % Set the color (from file)
set(tcs, 'EdgeColor','none');         % Set the edge color

% draw a reference frame (vehicle fixed)
line([0 1],[0 0],[0 0],'color','k','linewidth',3);
line([0 0],[0 1],[0 0],'color','k','linewidth',3);
line([0 0],[0 0],[0 1],'color','k','linewidth',3);

% draw a body fixed referenece frame

% define an example series of rotations
tspan = 1:1:100;
rot_vec = [1, 0, 0];
for ii = 1:length(tspan)
    R_b2i(:, :, ii) = expm(hat_map(rot_vec)*2*pi/100*tspan(ii));
end

switch type
    case 'gif'
        f = getframe;
        [im,map] = rgb2ind(f.cdata,256,'nodither');
    case 'movie'
%         M(1:length(tspan))= struct('cdata',[],'colormap',[]);
    nFrames = length(tspan);
    vidObj = VideoWriter([filename '.avi']);
    vidObj.Quality = 100;
    vidObj.FrameRate = 8;
    open(vidObj);
end

hold on
% line([0 boresight(1)],[0 boresight(2)],[0 boresight(3)],'color','k','linewidth',3);
for ii = 1:10:length(tspan)
    
    % rotate the mesh
    nTV = TV *R_b2i(:,:,ii)';
    
    % update the mesh
    set(tcs,'Vertices',nTV);
   
    % update the body axes
    bore_handle = line([0 sen_inertial(ii,1)],[0 sen_inertial(ii,2)],[0 sen_inertial(ii,3)],'color','k','linewidth',3);
    plot3(sen_inertial(1:ii,1),sen_inertial(1:ii,2),sen_inertial(1:ii,3),'b','linewidth',3);
    
    drawnow

    % render a frame
    switch type
        case 'gif'
            
            frame = getframe(1);
            im = frame2im(frame);
            [imind,cm] = rgb2ind(im,256);
            outfile = [filename '.gif'];
            
            % On the first loop, create the file. In subsequent loops, append.
            if ii==1
                imwrite(imind,cm,outfile,'gif','DelayTime',0,'loopcount',inf);
            else
                imwrite(imind,cm,outfile,'gif','DelayTime',0,'writemode','append');
            end
        case 'movie'
%             M(ii)=getframe(gcf,[0 0 560 420]); % leaving gcf out crops the frame in the movie.
            writeVideo(vidObj,getframe(gca));
        otherwise
            
            
    end
    delete(bore_handle)
end


% Output the movie as an avi file
switch type
    case 'gif'
        
        
    case 'movie'
%         movie2avi(M,[filename '.avi']);
    close(vidObj);
    
    otherwise
        
end

fprintf('\nFINISHED ANIMATION\n\n')
fprintf('\nLOOK FOR %s in current directory\n\n', filename)

