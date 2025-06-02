import com.hazelcast.client.HazelcastClient;
import com.hazelcast.core.HazelcastInstance;
import com.hazelcast.collection.IQueue;

public class QueueClient {
    public static void main(String[] args) throws Exception {
        HazelcastInstance client = HazelcastClient.newHazelcastClient();
        IQueue<String> queue = client.getQueue("bounded-queue");

        if (args.length > 0 && args[0].equals("writer")) {
            for (int i = 1; i <= 100; i++) {
                queue.put("Message " + i);
                System.out.println("📤 Written: Message " + i);
            }
        } else {
            while (true) {
                String msg = queue.take();
                System.out.println("📥 Received: " + msg);
            }
        }
    }
}
