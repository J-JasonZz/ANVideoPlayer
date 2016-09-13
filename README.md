# ANVideoPlayer


####能一行代码搞定视频播放的轻量级播放器
![](/Users/Memebox/Desktop/1111.gif)
![](/Users/Memebox/Desktop/2222.gif)

##集成步骤：
### 1. 实时同步预览把 ANVideoPlayer 文件夹拖入工程
### 2. 导入头文件 #import "ANVideoPlayerUtil.h"
### 3. ```[[ANVideoPlayerUtil shareUtil] playVideoWithStreamURL:@"http://baobab.wdjcdn.com/14571455324031.mp4"];```

##Example
```
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ANPlayerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KANPlayerTableViewCellReuseID];
    ANPlayerModel *model = self.dataSource[indexPath.row];
    [cell assginValueWithPlayerModel:model];
    
    cell.playButtonClick = ^{
        [[ANVideoPlayerUtil shareUtil] playVideoWithStreamURL:[NSURL URLWithString:model.playUrl]];
    };
    
    return cell;
}

```