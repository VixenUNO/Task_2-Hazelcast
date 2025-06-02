import com.hazelcast.client.HazelcastClient;
import com.hazelcast.core.HazelcastInstance;
import com.hazelcast.topic.ITopic;

clientConfig.getNetworkConfig().addAddress("localhost:5701");

public class TopicClient {
    public static void main(String[] args) throws Exception {
        HazelcastInstance client = HazelcastClient.newHazelcastClient();
        ITopic<String> topic = client.getTopic("demo-topic");

        if (args.length > 0 && args[0].equals("producer")) {
            for (int i = 1; i <= 100; i++) {
                topic.publish("Message " + i);
                System.out.println("📤 Published: Message " + i);
                Thread.sleep(100);
            }
        } else {
            topic.addMessageListener(message -> {
                System.out.println("📥 Received: " + message.getMessageObject());
            });

            System.out.println("🔄 Listening on topic...");
            Thread.sleep(15000); // слухаємо 15 секунд
        }

        client.shutdown();
    }
}
