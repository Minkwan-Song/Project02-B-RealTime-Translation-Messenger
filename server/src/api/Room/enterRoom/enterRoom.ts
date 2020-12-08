import generateToken from '@utils/generateToken';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

interface EnterInfo {
  nickname: string;
  avatar: string;
  lang: string;
  code: string;
  token: string;
}

export default {
  Mutation: {
    enterRoom: async (
      _: any,
      { nickname, avatar, lang, code }: EnterInfo,
      { pubsub }: any,
    ): Promise<{ userId: number; roomId: number; token: string }> => {
      const newUser = await prisma.user.create({
        data: {
          nickname,
          lang,
          avatar,
          rooms: {
            connect: { code },
          },
        },
        include: { rooms: true },
      });
      const jwtToken = generateToken(newUser, newUser.rooms[0].id);
      pubsub.publish('NEW_USER', { newUser });
      return { userId: newUser.id, roomId: newUser.rooms[0].id, token: jwtToken };
    },
  },
};
