'use strict';

module.exports = (robot) => {
  const post = (message, channelId) => new Promise(resolve => {
    robot.adapter.client._apiCall('chat.postMessage', {
      channel: channelId,
      text: message,
      as_user: true
    }, (res) => resolve(res));
  });

  const updateMessage = (message, channelId, ts) => new Promise(resolve => {
    robot.adapter.client._apiCall('chat.update', {
      channel: channelId,
      text: message,
      ts: ts
    }, (res) => resolve(res));
  });

  robot.hear(/test/, (msg) => {
    const channelId = robot.adapter.client.getChannelGroupOrDMByName(msg.envelope.room).id;
    post('  0% #', channelId).then(res => {
      const ts = res.ts;

      for (let i = 0; i <= 50; i ++) {
        setTimeout(() => { updateMessage(`${i * 2}% ${'#'.repeat(i)}`, channelId, ts) }, 50 * i);
      }
    });
  });
};
